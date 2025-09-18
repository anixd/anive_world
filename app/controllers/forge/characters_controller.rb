class Forge::CharactersController < Forge::BaseController
  before_action :set_character, only: %i[show edit update destroy]

  def index
    @pagy, @characters = pagy(policy_scope(Character).includes(:tags).order(title: :asc))
  end

  def show
    authorize @character
  end

  def new
    @character = Character.new
    authorize @character
  end

  def create
    @character = Character.new(character_params)
    @character.author = current_user
    authorize @character

    if @character.save
      redirect_to forge_character_path(@character), notice: "Character was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @character
  end

  def update
    authorize @character
    if @character.update(character_params)
      redirect_to forge_character_path(@character), notice: "Character was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @character
    @character.discard
    redirect_to forge_characters_path, notice: "Character was archived."
  end

  private

  def set_character
    @character = Character.includes(:tags).find_by!(slug: params[:id])
  end

  def character_params
    params.require(:character).permit(:title, :body, :life_status, :birth_date, :death_date, :tags_string)
  end
end
