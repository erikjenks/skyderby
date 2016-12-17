# The ".tes" format is a binary file without the header (16bytes/record).
# It only the data part of the ".tk2" format.
#
# Byte (DataType): Content =============================
# 00-01 (Word): Flag (bp0:Split mark, bp1:Intererst Point, bp2:Track point)
# 02-05 (LongInt): DateTime
# (bp0-5:Sec, bp6-11:Min, bp12-16:Hour, bp17-21:Day,
#     bp22-25:Month, bp26-31:Year-2000)
# 06-09 (LongInt): Latitude / 1.0e7 (Deg)
# 0A-0D (LongInt): Longitude / 1.0e7 (Deg)
# 0E-0F(SmallInt): Altitude(m)

module Skyderby
  module Parsers
    class TESParser < TrackParser
      def parse(_index = 0)
        track_points = []
        unpacked_string =
          @track_data.unpack('SLLLS' * (@track_data.length / 16))

        (0..(unpacked_string.count / 5 - 1)).each do |x|
          track_points << parse_row(unpacked_string, x * 5)
        end

        FileData.new(track_points, :wintec)
      end

      private

      def parse_row(unpacked_string, x)
        parse_point(
          datetime: unpacked_string[x + 1],
          latitude: unpacked_string[x + 2] / 1.0e7,
          longitude: unpacked_string[x + 3] / 1.0e7,
          height: unpacked_string[x + 4]
        )
      end

      def parse_point(row)
        Point.new(
          gps_time: parse_datetime(row[:datetime]),
          latitude: row[:latitude],
          longitude: row[:longitude],
          abs_altitude: row[:height])
      end

      def parse_datetime(val)
        binarydate = val.to_s(2).reverse

        Time.zone.parse("#{parse_date(binarydate)}T#{parse_time(binarydate)}")
      end

      def parse_date(binarydate)
        year = "20#{binarydate[26..31].reverse.to_i(2)}"
        month = binarydate[22..25].reverse.to_i(2)
        month = month < 10 ? "0#{month}" : month.to_s
        day = binarydate[17..21].reverse.to_i(2).to_s

        "#{year}-#{month}-#{day}"
      end

      def parse_time(binarydate)
        hour = binarydate[12..16].reverse.to_i(2).to_s
        min = binarydate[6..11].reverse.to_i(2).to_s
        sec = binarydate[0..5].reverse.to_i(2).to_s

        "#{hour}:#{min}:#{sec}"
      end
    end
  end
end
