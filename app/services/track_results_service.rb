class TrackResultsService
  attr_reader :track

  STEP_SIZE = 50
  SKYDIVE_RANGE = 1000
  MINIMUM_SKYDIVE_ALTITUDE = 1000

  def initialize(trk)
    @track = trk
  end

  def execute
    track.destroy_results  
    
    results = ranges_to_score.map do |range|
      WindowRangeFinder.new(track_points)
                     .execute(from_altitude: range[:start_altitude],
                              to_altitude:   range[:end_altitude])
    end

    [:speed, :distance, :time].each do |task|
      best_task_result = results.max_by { |x| x.send(task) }
      track.track_results.create(discipline: task,
                                 range_from: best_task_result.start_altitude,
                                 range_to:   best_task_result.end_altitude,
                                 result:     best_task_result.send(task))
    end
  end

  def track_points
    @track_points ||=
      track.points.trimmed.pluck_to_hash(
        'to_timestamp(gps_time_in_seconds) AT TIME ZONE \'UTC\' as gps_time',
        "#{@track.point_altitude_field} AS altitude",
        :latitude,
        :longitude)
    @track_points
  end

  def ranges_to_score
    altitude_bounds = track.altitude_bounds
    
    # round to STEP_SIZE. Max to lower, min to upper value
    max_altitude = altitude_bounds[:max_altitude] - altitude_bounds[:max_altitude] % STEP_SIZE
    min_track_altitude = altitude_bounds[:min_altitude] + STEP_SIZE - altitude_bounds[:min_altitude] % STEP_SIZE
    min_altitude = [min_track_altitude, MINIMUM_SKYDIVE_ALTITUDE].max
    elevation = max_altitude - min_altitude

    return [{
      start_altitude: altitude_bounds[:max_altitude],
      end_altitude: altitude_bounds[:min_altitude]
    }] if track.base? || elevation <= SKYDIVE_RANGE

    ranges = []
    steps = ((elevation - SKYDIVE_RANGE) / STEP_SIZE).floor
    steps.times do |step|
      altitude_change = STEP_SIZE * step
      ranges << { 
        start_altitude: max_altitude - altitude_change,
        end_altitude:   max_altitude - SKYDIVE_RANGE - altitude_change
      }
    end

    ranges
  end
end
