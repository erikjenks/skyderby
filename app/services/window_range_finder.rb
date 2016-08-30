class WindowRangeFinder
  attr_reader :points

  # Order matters
  ALLOWED_FILTERS = [:from_altitude,
                     :from_vertical_speed,
                     :duration,
                     :elevation,
                     :to_altitude]

  def initialize(points)
    @points = points
  end

  def execute(args)
    ALLOWED_FILTERS.each do |filter|
      send(filter, args[filter]) if args.has_key? filter
    end

    TrackSegment.new(points)
  end

  private

  def from_altitude(altitude)
    index = points.index { |x| x[:altitude] <= altitude }

    return if index < 1

    interpolated_point = PointInterpolation.new(
      points[index - 1],
      points[index]
    ).execute(by: :altitude, with_value: altitude)

    @points = [interpolated_point] + points[index..-1]
  end

  def to_altitude(altitude)
    index = points.index { |x| x[:altitude] <= altitude }

    interpolated_point = PointInterpolation.new(
      points[index - 1],
      points[index]
    ).execute(by: :altitude, with_value: altitude)

    @points = points[0..(index - 1)] + [interpolated_point]
  end
end
