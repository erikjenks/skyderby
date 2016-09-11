# == Schema Information
#
# Table name: tournament_match_competitors
#
#  id                       :integer          not null, primary key
#  result                   :decimal(10, 3)
#  tournament_competitor_id :integer
#  tournament_match_id      :integer
#  track_id                 :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  is_winner                :boolean
#  is_disqualified          :boolean
#  is_lucky_looser          :boolean
#  notes                    :string(510)
#  earn_medal               :integer
#

class TournamentMatchCompetitor < ActiveRecord::Base

  SECONDS_BEFORE_START = 10

  enum earn_medal: [:gold, :silver, :bronze]

  belongs_to :tournament_competitor
  belongs_to :tournament_match
  belongs_to :track

  before_save :calculate_result
  before_save :replace_nan_with_zero

  delegate :start_time, to: :tournament_match

  def calculate_result
    return unless track
    return if (result || 0) > 0

    begin
      intersection_point = PathIntersectionFinder.new(
        track_points, 
        finish_line
      ).execute
      
      self.result = (intersection_point[:gps_time].to_f - start_time.to_f).round(3)
    rescue PathIntersectionFinder::IntersectionNotFound
      self.result = 0
      self.is_disqualified = true
      self.notes = "Didn't intersected finish line"
    end
  end
  
  private

  def track_points
    track.points
         .freq_1Hz
         .trimmed(seconds_before_start: SECONDS_BEFORE_START)
         .pluck_to_hash(
           :fl_time,
           'to_timestamp(gps_time_in_seconds) AT TIME ZONE \'UTC\' as gps_time',
           "#{track.point_altitude_field} AS altitude",
           :latitude,
           :longitude)
  end

  def finish_line
    tournament_match.tournament.finish_line
  end

  def replace_nan_with_zero
    return if result.nil?
    self.result = 0 if result.nan? || result.infinite?
  end
end
