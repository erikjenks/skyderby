class Event < ActiveRecord::Base
  has_many :event_tracks, through: :rounds
  has_many :users, through: :competitors
  has_many :organizers
  has_many :competitors
  has_many :rounds
  has_many :participation_forms
  has_many :invitations
  has_many :event_documents

  scope :coming, lambda { where('DATE(end_at) > ?', Date.today)}
  scope :completed, lambda { where('DATE(end_at) < ?', Date.today)}

  Results_struct = Struct.new(:ws_class, :usage, :competitors)
  Competitor_struct = Struct.new(:name, :id, :user_id, :wingsuit, :time,
                                 :time_points, :distance, :distance_points,
                                 :speed, :speed_points, :total)

  def results
    # TODO: if event.type.eql? Time_Distance_Speed_PL
    process_results
  end

  # @return [Array]
  def competitors_table

    advanced_comps = Results_struct.new(:advanced, true, [])
    intermediate_comps = Results_struct.new(:intermediate, true, [])
    rookie_comps = Results_struct.new(:rookie, !self.merge_intermediate_and_rookie, [])
    tracksuit_comps = Results_struct.new(:tracksuit, self.allow_tracksuits, [])

    self.competitors.each do |comp|

      comp_el = Competitor_struct.new(comp.user.name, comp.id, comp.user.id, comp.wingsuit.name, [], nil, [], nil, [], nil, nil)

      if ws_class(comp) == :advanced
        advanced_comps.competitors << comp_el
      elsif ws_class(comp) == :intermediate
        intermediate_comps.competitors << comp_el
      elsif ws_class(comp) == :rookie
        if rookie_comps.usage
          rookie_comps.competitors << comp_el
        else
          intermediate_comps.competitors << comp_el
        end
      elsif ws_class(comp) == :tracksuit && tracksuit_comps.usage
        tracksuit_comps.competitors << comp_el
      end

    end

    results_ary = []
    results_ary << advanced_comps
    results_ary << intermediate_comps
    results_ary << rookie_comps if rookie_comps.usage
    results_ary << tracksuit_comps if tracksuit_comps.usage

    results_ary

  end

  # TODO scopes for rounds
  def time_rounds
    rounds_by_discipline Discipline.time
  end

  def distance_rounds
    rounds_by_discipline Discipline.distance
  end

  def speed_rounds
    rounds_by_discipline Discipline.speed
  end

  private

  def query_result

    Competitor.select('competitors.*, rounds.*, event_tracks.*, ws_classes.name ws_class')
                .joins('LEFT OUTER JOIN rounds ON rounds.event_id = competitors.event_id')
                .joins('LEFT OUTER JOIN wingsuits ON wingsuits.id = competitors.wingsuit_id')
                .joins('LEFT OUTER JOIN ws_classes ON ws_classes.id = wingsuits.ws_class_id')
                .joins('LEFT OUTER JOIN event_tracks ON event_tracks.competitor_id = competitors.id AND round_id = rounds.id')
                .where(:event_id => self.id)
                .to_a.map(&:serializable_hash)

  end

  def query_max_results

    Round.select('rounds.id, max(event_tracks.result) max_result')
          .where(:event_id => 2)
          .joins('LEFT OUTER JOIN event_tracks ON event_tracks.round_id = rounds.id')
          .group('rounds.id')
          .to_a.map(&:serializable_hash)

  end

  def process_results

    advanced_comps = Results_struct.new(:advanced, true, [])
    intermediate_comps = Results_struct.new(:intermediate, true, [])
    rookie_comps = Results_struct.new(:rookie, !self.merge_intermediate_and_rookie, [])
    tracksuit_comps = Results_struct.new(:tracksuit, self.allow_tracksuits, [])

    max_results = query_max_results

    self.competitors.each do |comp|

      comp_el = Competitor_struct.new(comp.user.name, comp.id, comp.user.id, comp.wingsuit.name, [], 0, [], 0, [], 0, 0)

      comp.event_tracks.each do |ev_track|

        max = max_results.find { |rnd| rnd['id'] == ev_track.round.id }
        points = 0
        points = (ev_track.result / max['max_result'] * 100).to_i unless max.nil?

        if ev_track.round.discipline == Discipline.time
          comp_el.time << {:id => ev_track.round.id, :result => ev_track.result, :points => points}
        elsif ev_track.round.discipline == Discipline.distance
          comp_el.distance << {:id => ev_track.round.id, :result => ev_track.result, :points => points}
        elsif ev_track.round.discipline == Discipline.speed
          comp_el.speed << {:id => ev_track.round.id, :result => ev_track.result, :points => points}
        end
      end
      comp_el.total = 0

      if ws_class(comp) == :advanced
        advanced_comps.competitors << comp_el
      elsif ws_class(comp) == :intermediate
        intermediate_comps.competitors << comp_el
      elsif ws_class(comp) == :rookie
        if rookie_comps.usage
          rookie_comps.competitors << comp_el
        else
          intermediate_comps.competitors << comp_el
        end
      elsif ws_class(comp) == :tracksuit && tracksuit_comps.usage
        tracksuit_comps.competitors << comp_el
      end

    end

    # total calc and sorting
    time_rounds_count = time_rounds.count
    distance_rounds_count = distance_rounds.count
    speed_rounds_count = distance_rounds.count

    [advanced_comps, intermediate_comps, rookie_comps, tracksuit_comps].each do |comp_class|
      comp_class.competitors.each do |comp|

        if time_rounds_count != 0
          comp.time_points = comp.time.map{ |round| round[:points] }.inject(0, :+) / time_rounds_count
        end
        if distance_rounds_count !=0
          comp.distance_points = comp.distance.map{ |round| round[:points] }.inject(0, :+) / distance_rounds_count
        end
        if speed_rounds_count != 0
          comp.speed_points = comp.speed.map{ |round| round[:points] }.inject(0, :+) / speed_rounds_count
        end

        comp.total = comp.time_points + comp.distance_points + comp.speed_points
      end
    end

    results_ary = []
    results_ary << advanced_comps
    results_ary << intermediate_comps
    results_ary << rookie_comps if rookie_comps.usage
    results_ary << tracksuit_comps if tracksuit_comps.usage

    results_ary

  end

  def ws_class(competitor)
    competitor.wingsuit.ws_class.name.downcase.to_sym
  end

  def rounds_by_discipline(discipline)
    self.rounds.where(:discipline => discipline).order(:name)
  end

end