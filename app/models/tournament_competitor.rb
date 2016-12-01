# == Schema Information
#
# Table name: tournament_competitors
#
#  id            :integer          not null, primary key
#  tournament_id :integer
#  profile_id    :integer
#  wingsuit_id   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TournamentCompetitor < ApplicationRecord
  belongs_to :tournament
  belongs_to :profile
  belongs_to :wingsuit

  delegate :name, to: :profile
end
