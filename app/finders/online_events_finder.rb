class OnlineEventsFinder
  def initialize(track)
    @track = track
  end

  def execute
    return [] unless available_for_scoring

    comps = VirtualCompetition.order(:name)
    comps = comps.skydive if track.skydive?
    comps = comps.base if track.base?

    comps = comps.tracksuit if track.tracksuit?
    comps = comps.wingsuit if track.wingsuit?

    comps = comps.where(
      ':period BETWEEN period_from AND period_to',
      period: track.recorded_at
    )

    comps =
      if track.place
        comps.where(
          'place_id = :place_id OR place_id IS NULL',
          place_id: track.place_id
        )
      else
        comps.where('place_id IS NULL')
      end
  end

  private

  attr_reader :track

  def available_for_scoring
    track.public_track? && track.wingsuit && track.pilot
  end
end
