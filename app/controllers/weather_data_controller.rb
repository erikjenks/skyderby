class WeatherDataController < ApplicationController
  before_action :load_weather_datumable
  before_action :authorize_parent, except: :index
  before_action :set_weather_datum, only: [:edit, :update, :destroy]
  before_action :set_view_units

  respond_to :js

  def index
    respond_to do |format|
      format.html { redirect_to @weather_datumable }
      format.js { respond_with_index }
    end
  end

  def create
    @weather_record = @weather_datumable.weather_data.new weather_data_params

    if @weather_record.save
      respond_with_index(change: true)
    else
      render 'errors/ajax_errors', locals: { errors: @weather_datum.errors }
    end
  end

  def update
    if @weather_datum.update weather_data_params
      respond_with_index(change: true)
    else
      render 'errors/ajax_errors', locals: { errors: @weather_datum.errors }
    end
  end

  def destroy
    if @weather_datum.destroy
      @weather_datum
    else
      render 'errors/ajax_errors', locals: { errors: @weather_datum.errors }
    end
  end

  def new; end

  def edit
    @weather_data = weather_data_model
  end

  private

  def respond_with_index(change: false)
    @weather_data = weather_data_model
    @weather_datum = WeatherDatum.new

    render :index, locals: { change: change }
  end

  def weather_data_model
    klass =
      begin
        WeatherData.const_get("#{@weather_datumable.class.name}Weather")
      rescue NameError
        WeatherData::Default
      end
    klass.new(@weather_datumable)
  end

  def load_weather_datumable
    klass = [Event, Track, Place].detect { |c| params["#{c.name.underscore}_id"] }
    @weather_datumable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def set_weather_datum
    @weather_datum = WeatherDatum.find(params[:id])
  end

  def authorize_parent
    authorize! :update, @weather_datumable
  end

  def set_view_units
    @view_units = { altitude: index_params[:altitude_unit] || 'm',
                    wind_speed: index_params[:wind_speed_unit] || 'ms' }
  end

  def index_params
    params.permit(:altitude_unit, :wind_speed_unit)
  end
  helper_method :index_params

  def weather_data_params
    params.require(:weather_datum).permit :actual_on,
                                          :altitude,
                                          :altitude_in_units,
                                          :altitude_unit,
                                          :wind_speed,
                                          :wind_speed_in_units,
                                          :wind_speed_unit,
                                          :wind_direction
  end
end
