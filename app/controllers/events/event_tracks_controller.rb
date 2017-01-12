# encoding: utf-8
module Events
  class EventTracksController < ApplicationController
    include EventLoading
    include UnitsHelper
    include PreferencesHelper

    before_action :set_event_track, only: [:show, :edit, :update, :destroy]

    load_resource :event
    before_action :authorize_update_event, except: :show
    before_action :authorize_show_event, only: :show

    load_and_authorize_resource :event_track, through: :event

    def create
      @event_track = @event.event_tracks.new event_track_params
      @event_track.current_user = current_user

      if @event_track.save
        respond_to do |format|
          format.js { respond_with_scoreboard }
        end
      else
        respond_with_errors @event_track.errors
      end
    end

    def update
      if @event_track.update event_track_params
        respond_to do |format|
          format.js { respond_with_scoreboard }
        end
      else
        respond_with_errors @event_track.errors
      end
    end

    def destroy
      if @event_track.destroy
        respond_to do |format|
          format.js { respond_with_scoreboard }
          format.json { head :no_content }
        end
      else
        respond_with_errors @event_track.errors
      end
    end

    def new
      @event_track = EventTrack.new event_track_params
    end

    def edit; end

    def show
      respond_to do |format|
        format.html do
          redirect_to track_path(@event_track.track,
                                 f: @event.range_from,
                                 t: @event.range_to)
        end
        format.js do
          @track_data = Tracks::TrackPresenter::Competition.new(
            @event_track,
            Units[preferred_charts_units]
          )
          @track_data.load
        end
      end
    end

    private

    def set_event_track
      @event_track = EventTrack.find(params[:id])
    end

    def respond_with_scoreboard
      create_scoreboard(params[:event_id], @display_raw_results)
      render template: 'events/event_tracks/scoreboard_with_highlight'
    end

    def event_track_params
      params.require(:event_track).permit(
        :competitor_id,
        :round_id,
        :track_id,
        :track_from,
        :is_disqualified,
        :disqualification_reason,
        track_attributes: [
          :file,
          :profile_id,
          :place_id,
          :wingsuit_id
        ]
      )
    end

    def show_params
      params.permit(:charts_mode, :charts_units)
    end
    helper_method :show_params

    def authorize_update_event
      authorize! :update, @event
    end

    def authorize_show_event
      authorize! :read, @event
    end
  end
end
