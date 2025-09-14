class Forge::Timeline::ErasController < Forge::BaseController
  before_action :set_era, only: %i[show edit update destroy]
  before_action :set_form_options, only: %i[new edit create update]

  def index
    @eras = policy_scope(Timeline::Era).includes(:calendar).order("timeline_calendars.name, timeline_eras.order_index")
  end

  def new
    @era = Timeline::Era.new
    authorize @era
  end

  def create
    @era = Timeline::Era.new(era_params)
    authorize @era
    if @era.save
      redirect_to forge_timeline_eras_path, notice: "Era created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @era
  end

  def update
    authorize @era
    if @era.update(era_params)
      redirect_to forge_timeline_eras_path, notice: "Era updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @era
    @era.destroy
    redirect_to forge_timeline_eras_path, notice: "Era destroyed."
  end

  private

  def set_era
    @era = Timeline::Era.find(params[:id])
  end

  def set_form_options
    @calendars = Timeline::Calendar.order(:name)
  end

  def era_params
    params.require(:timeline_era).permit(:name, :order_index, :start_absolute_year, :end_absolute_year, :calendar_id)
  end
end
