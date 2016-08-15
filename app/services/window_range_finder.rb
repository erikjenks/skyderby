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

    interpolated_point = 
      interpolate_by_altitude(points[index - 1], points[index], altitude)
    
    @points = [interpolated_point] + points[index..-1]
  end

  def to_altitude(altitude)
    index = points.index { |x| x[:altitude] <= altitude }

    interpolated_point = 
      interpolate_by_altitude(points[index - 1], points[index], altitude)

    @points = points[0..(index - 1)] + [interpolated_point]
  end

  def interpolate_by_altitude(first, second, altitude)
    k = (first[:altitude] - altitude) / (first[:altitude] - second[:altitude])

    new_point = first.clone
    new_point[:altitude]  = altitude
    [:gps_time, :latitude, :longitude, :h_speed, :v_speed, :distance].each do |key|
      new_point[key] = interpolate_field(first, second, key, k) if new_point.has_key? key
    end

    new_point
  end

  def interpolate_field(first, second, key, k)
    first[key] + (second[key] - first[key]) * k
  end
end
