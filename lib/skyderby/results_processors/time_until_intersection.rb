require 'geometry/geometry'

module Skyderby
  module ResultsProcessors
    class TimeUntilIntersection
      class IntersectionNotFound < StandardError; end

      def initialize(track_points, params)
        @track_points = track_points

        @start_time = params[:start_time]
        @finish_segment = flight_segment(params[:finish_line])
      end

      def calculate
        intersected_segment =
          @track_points.each_cons(2).detect do |pair|
            segment = flight_segment(pair)
            segment.intersects_with? @finish_segment
          end

        raise IntersectionNotFound unless intersected_segment

        segment = flight_segment(intersected_segment)
        intersection_point = segment.intersection_point_with(@finish_segment)

        hash_point = Skyderby::Geospatial.mercator_to_coordinates(
          intersection_point.x,
          intersection_point.y
        )

        interpolate_by_field = interpolation_field(intersected_segment)
        finish_time = PointInterpolation.new(
          intersected_segment.first,
          intersected_segment.last
        ).execute(
          by: interpolate_by_field,
          with_value: hash_point[interpolate_by_field]
        )[:gps_time]

        (finish_time.to_f - @start_time.to_f).round(3)
      end

      private

      def flight_segment(pair)
        mercator_start = Skyderby::Geospatial.coordinates_to_mercator(
          pair.first[:latitude],
          pair.first[:longitude]
        )

        mercator_end = Skyderby::Geospatial.coordinates_to_mercator(
          pair.last[:latitude],
          pair.last[:longitude]
        )

        Geometry::Segment.new_by_arrays(
          [mercator_start[:x], mercator_start[:y]],
          [mercator_end[:x],   mercator_end[:y]]
        )
      end

      def interpolation_field(segment)
        if (segment.first[:latitude] - segment.last[:latitude]).abs >
          (segment.first[:longitude] - segment.last[:longitude]).abs
          :latitude
        else
          :longitude
        end
      end
    end
  end
end
