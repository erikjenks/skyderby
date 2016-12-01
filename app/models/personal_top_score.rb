# == Schema Information
#
# Table name: personal_top_scores
#
#  rank                   :integer
#  virtual_competition_id :integer
#  track_id               :integer
#  result                 :float
#  highest_speed          :float
#  highest_gr             :float
#  profile_id             :integer
#  wingsuit_id            :integer
#  recorded_at            :datetime
#

class PersonalTopScore < ApplicationRecord
  belongs_to :virtual_competition
  belongs_to :track
  belongs_to :profile
  belongs_to :wingsuit

  private

  def read_only?
    true
  end
end
