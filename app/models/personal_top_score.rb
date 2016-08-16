class PersonalTopScore < ActiveRecord::Base
  belongs_to :virtual_competition
  belongs_to :track
  belongs_to :profile
  belongs_to :wingsuit

  private

  def read_only?
    true
  end
end
