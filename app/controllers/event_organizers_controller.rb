class EventOrganizersController < ApplicationController
  before_action :set_event_organizer, only: [:destroy]

  load_resource :event
  before_filter :authorize_event

  load_and_authorize_resource :event_organizer, through: :event

  def create
    @event_organizer = @event.event_organizers.new event_organizer_params

    if @event_organizer.save
      @event_organizer
    else
      render json: @event_organizer.errors, status: :unprocessible_entry
    end
  end

  def destroy
    @event_organizer.destroy
    head :no_content
  end

  private

  def set_event_organizer
    @event_organizer = EventOrganizer.find(params[:id])
  end

  def event_organizer_params
    params.require(:event_organizer).permit(:event_id, :user_profile_id)
  end

  def authorize_event
    authorize! :update, @event
  end
end
