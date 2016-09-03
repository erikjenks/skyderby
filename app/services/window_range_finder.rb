class WindowRangeFinder
  class UnknownFilter   < StandardError; end
  class ValueOutOfRange < StandardError; end

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
    args.each { |filter, _| raise UnknownFilter, filter unless ALLOWED_FILTERS.include? filter }

    ALLOWED_FILTERS.each do |filter|
      send(filter, args[filter]) if args.has_key? filter
    end

    TrackSegment.new(points)
  end

  private

  attr_reader :points

  def from_altitude(altitude)
    index = points.index { |x| x[:altitude] <= altitude }

    raise ValueOutOfRange if index.nil? || index < 1

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

  def from_vertical_speed(speed)
    index = points.index { |x| x[:v_speed] >= speed }

    raise ValueOutOfRange if index.nil? || index < 1

    interpolated_point = PointInterpolation.new(
      points[index - 1],
      points[index]
    ).execute(by: :v_speed, with_value: speed)

    @points = [interpolated_point] + points[index..-1]
  end
end
