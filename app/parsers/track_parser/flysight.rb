require 'csv'

module TrackParser
  class Flysight
    TIME              = 0
    LATITUDE          = 1
    LONGITUDE         = 2
    ALTITUDE          = 3
    SPEED_NORTH       = 4
    SPEED_EAST        = 5
    SPEED_VERTICAL    = 6
    VERTICAL_ACCURACY = 8

    MAX_ACCURACY = 70

    MS_IN_KMH = 3.6

    def initialize(args = {})
      @file_path = args[:path]
    end

    def parse
      track_points = []
      CSV.foreach(file_path, skip_lines: /^[^0-9]{4}/) do |row|
        next if row[VERTICAL_ACCURACY].to_f > MAX_ACCURACY
        track_points << parse_row(row)
      end

      track_points
    end

    private

    def parse_row(row)
      PointRecord.new.tap do |r|
        r.latitude     = BigDecimal.new row[LATITUDE]
        r.longitude    = BigDecimal.new row[LONGITUDE]
        r.abs_altitude = BigDecimal.new row[ALTITUDE]
        r.h_speed = ground_speed_from_components(
          north: row[SPEED_NORTH],
          east: row[SPEED_EAST]
        )
        r.v_speed = vertical_speed(row[SPEED_VERTICAL])
        r.gps_time = gps_time(row[TIME].to_s)
      end
    end

    def ground_speed_from_components(north:, east:)
      Math.sqrt(north.to_f**2 + east.to_f**2) * MS_IN_KMH
    end

    def vertical_speed(value)
      value.to_f * MS_IN_KMH
    end

    def gps_time(time_str)
      Time.strptime(time_str, '%Y-%m-%dT%H:%M:%S.%L %Z')
    end

    attr_reader :file_path
  end
end
