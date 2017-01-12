module Tracks
  module TrackPresenter
    PRESENTERS = {
      flysight: Flysight,
      cyber_eye: Flysight
    }.with_indifferent_access.freeze

    def self.for(format)
      PRESENTERS[format] || Default
    end
  end
end
