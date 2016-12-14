require 'tracks/jump_range_finder'

class CreateTrackService
  # Search radius for place in km
  # Base exit described as exit coordinates
  # Skydive dropzone descriped as landing area coordinates
  BASE_SEARCH_RADIUS = 1
  SKYDIVE_SEARCH_RADIUS = 10

  def initialize(params, segment: 0)
    @params = params.dup
    @track_index = segment
  end

  def execute
    ActiveRecord::Base.transaction do
      # Create track with params
      @track = Track.new(@params)
      @track.pilot = @track.user.profile if @track.user && !@params[:profile_id]

      # Read file with track and set logger type
      track_data = @track.track_file.track_file_data(@track_index)
      points = PointsService.new(track_data.points).execute
      @track.gps_type = track_data.logger

      jump_range = JumpRangeFinder.range_for points
      @track.ff_start = jump_range.start_time
      @track.ff_end = jump_range.end_time

      # Find and set place as closest to start of jump range
      # and set ground level if place found as place msl offset
      place = find_place jump_range.start_point, search_radius
      @track.place = place
      @track.ground_level = place.msl if place

      # Record track, then assign to it points and
      # record points to db
      @track.skip_jobs = true
      @track.save!
      record_points points, @track.id
      @track.skip_jobs = false

      @track.recorded_at = points.last.gps_time

      @track.save
      @track
    end
  end

  def search_radius
    @track.base? ? BASE_SEARCH_RADIUS : SKYDIVE_SEARCH_RADIUS
  end

  def find_place(start_point, radius)
    Place.nearby(start_point, radius).first
  end

  def record_points(track_points, track_segment_id)
    sql = "INSERT INTO points (#{points_columns})
           VALUES #{points_values(track_points, track_segment_id)}"

    ActiveRecord::Base.connection.execute sql
  end

  def points_values(track_points, track_id)
    inserts = []

    track_points.each do |point|
      inserts << "(
        #{point.gps_time.to_f},
        #{point.latitude},
        #{point.longitude},
        #{point.abs_altitude},
        #{point.distance},
        #{point.fl_time},
        #{point.v_speed},
        #{point.h_speed},
        #{track_id},
        '#{current_time}',
        '#{current_time}'
      )"
    end

    inserts.join(', ')
  end

  def current_time
    Time.zone.now.to_s(:db)
  end

  def points_columns
    ' gps_time_in_seconds,
      latitude,
      longitude,
      abs_altitude,
      distance,
      fl_time,
      v_speed,
      h_speed,
      track_id,
      updated_at,
      created_at'
  end
end
