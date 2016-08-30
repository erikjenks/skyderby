require 'spec_helper'

describe WindowRangeFinder do
  it 'trim until specified altitude' do
    range_finder = WindowRangeFinder.new(sample_points)
    track_segment = range_finder.execute(from_altitude: 2900)

    expect(track_segment.size).to eq(7)

    expect(track_segment.start_point[:gps_time]).to be_within(0.1).of(15.5)
    expect(track_segment.start_point[:altitude]).to eq(2900)
    expect(track_segment.start_point[:latitude]).to be_within(0.000001).of(1.65)
    expect(track_segment.start_point[:longitude]).to be_within(0.000001).of(2.35)
    expect(track_segment.start_point[:v_speed]).to be_within(0.1).of(125)
  end

  it 'trim after specified altitude' do
  end

  it 'trim from start by speed' do
  end

  def sample_points
    [
      { gps_time: 11, latitude: 0.0, longitude: 0.0, altitude: 3050, v_speed: 100 },
      { gps_time: 14, latitude: 1.1, longitude: 1.9, altitude: 2950, v_speed: 120 },
      { gps_time: 17, latitude: 2.2, longitude: 2.8, altitude: 2850, v_speed: 130 },
      { gps_time: 21, latitude: 3.3, longitude: 3.7, altitude: 2750, v_speed: 140 },
      { gps_time: 24, latitude: 4.4, longitude: 4.6, altitude: 2650, v_speed: 150 },
      { gps_time: 27, latitude: 5.5, longitude: 5.5, altitude: 2550, v_speed: 160 },
      { gps_time: 31, latitude: 6.6, longitude: 6.4, altitude: 2450, v_speed: 170 },
      { gps_time: 34, latitude: 7.7, longitude: 7.3, altitude: 2350, v_speed: 180 }
    ]
  end
end
