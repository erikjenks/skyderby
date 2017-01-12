module Tracks
  module TrackPresenter
    class Competition < Base
      def initialize(event_track, units)
        @event_track = event_track
        super(event_track.track, 
              event_track.range_from,
              event_track.range_to,
              units
             )
      end

      def time
        @time ||=
          if @event_track.round_discipline == 'time'
            @event_track.result
          else
            super
          end
      end

      def distance
        @distance ||= distance_presentation(track_distance)
      end

      def trajectory_distance
        distance_presentation(track_trajectory_distance)
      end

      private

      def track_distance
        if @event_track.round_discipline == 'distance'
          @event_track.result
        else
          straight_line_distance
        end
      end
    end
  end
end
