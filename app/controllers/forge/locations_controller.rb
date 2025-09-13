class Forge::LocationsController < Forge::BaseController
  before_action :set_location, only: %i[show edit update destroy]
  before_action :set_form_options, only: %i[new edit create update]

  def index
    @pagy, @locations = pagy(policy_scope(Location).order(title: :asc))
  end

  def show
    authorize @location
  end

  def new
    @location = Location.new
    authorize @location
  end

  def create
    @location = Location.new(location_params)
    @location.author = current_user
    authorize @location

    if @location.save
      redirect_to forge_location_path(@location), notice: "Location was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @location
  end

  def update
    authorize @location
    if @location.update(location_params)
      redirect_to forge_location_path(@location), notice: "Location was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @location
    @location.discard
    redirect_to forge_locations_path, notice: "Location was successfully archived."
  end

  private

  def set_location
    @location = Location.find_by!(slug: params[:id])
  end

  def set_form_options
    # Загружаем все локации для dropdown, исключая текущую (чтобы не сделать её родителем самой себе)
    @parent_location_options = Location.where.not(id: @location&.id).order(:title)
  end

  def location_params
    params.require(:location).permit(:title, :body, :parent_location_id)
  end
end
