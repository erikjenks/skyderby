class CreateTrackService
  # Search radius for place in km
  # Base exit described as exit coordinates
  # Skydive dropzone descriped as landing area coordinates
  BASE_SEARCH_RADIUS = 1
  SKYDIVE_SEARCH_RADIUS = 10

  def initialize(params, segment: 0)
    @params = params.dup
    @segment = segment
  end

  def execute
    ActiveRecord::Base.transaction do
      # Create track with params
      @track = Track.new(@params)
      @track.pilot = @track.user.profile if @track.user && !@params[:profile_id]

      # Read file with track and set logger type
      file_path = @track.track_file.file_path
      @track.gps_type = @track.track_file.file_format
      points = read_points_from_file(
        path: file_path,
        segment: segment,
        format: @track.gps_type
      )

      jump_range = JumpRangeFinder.for(@track.kind).new(points).execute
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
      Point.bulk_insert points: points, track_id: @track.id
      @track.skip_jobs = false

      @track.recorded_at = points.last.gps_time

      @track.save
      @track
    end
  end

  private

  attr_reader :segment

  def read_points_from_file(path:, segment:, format:)
    points = TrackParser.for(format).new(
      path: path,
      segment: segment
    ).parse

    PointsProcessor.for(format).new(points).execute
  end

  def search_radius
    @track.base? ? BASE_SEARCH_RADIUS : SKYDIVE_SEARCH_RADIUS
  end

  def find_place(start_point, radius)
    Place.nearby(start_point, radius).first
  end
end
