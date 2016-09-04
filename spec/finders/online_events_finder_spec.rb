require 'spec_helper'

describe OnlineEventsFinder do
  let(:worldwide_comp) { create :online_event }
  let(:place_comp) { create :online_event, :place_specific }
  let(:last_year_comp) { create :online_event, :last_year }

  let(:track1) { create :empty_track }
  let(:track2) { create :empty_track, :with_place }

  context 'only worldwide' do
    subject { OnlineEventsFinder.new(track1).execute }

    it { is_expected.to include(worldwide_comp) }
    it { is_expected.not_to include(place_comp) }
    it { is_expected.not_to include(last_year_comp) }
  end

  context 'worldwide and place specific' do
    subject { OnlineEventsFinder.new(track2).execute }

    it { is_expected.to include(worldwide_comp) }
    it { is_expected.to include(place_comp) }
    it { is_expected.not_to include(last_year_comp) }
  end

  it "returns blank array if track isn't public" do
    track = create(:empty_track)
    track.private_track!

    worldwide_comp = create :online_event

    expect(OnlineEventsFinder.new(track).execute).not_to include(worldwide_comp)
  end

  it "returns blank array if track from unregistered user" do
    track = create(:empty_track)
    track.pilot = nil

    worldwide_comp = create :online_event

    expect(OnlineEventsFinder.new(track).execute).not_to include(worldwide_comp)
  end

  it "returns blank array if track in custom suit" do
    track = create(:empty_track)
    track.wingsuit = nil

    worldwide_comp = create :online_event

    expect(OnlineEventsFinder.new(track).execute).not_to include(worldwide_comp)
  end
end
