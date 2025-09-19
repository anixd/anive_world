# frozen_string_literal: true

class Forge::Timeline::CalendarsController < Forge::BaseController
  before_action :set_calendar, only: %i[show edit update destroy]

  def index
    @calendars = policy_scope(Timeline::Calendar).order(:name)
  end

  def show
    authorize @calendar
  end

  def new
    @calendar = Timeline::Calendar.new
    authorize @calendar
  end

  def create
    @calendar = Timeline::Calendar.new(calendar_params)
    authorize @calendar
    if @calendar.save
      redirect_to forge_timeline_calendars_path, notice: "Calendar created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @calendar
  end

  def update
    authorize @calendar
    if @calendar.update(calendar_params)
      redirect_to forge_timeline_calendars_path, notice: "Calendar updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @calendar
    @calendar.destroy
    redirect_to forge_timeline_calendars_path, notice: "Calendar destroyed."
  end

  private

  def set_calendar
    @calendar = Timeline::Calendar.find(params[:id])
  end

  def calendar_params
    params.require(:timeline_calendar).permit(:name, :epoch_name, :absolute_year_of_epoch, :description)
  end
end
