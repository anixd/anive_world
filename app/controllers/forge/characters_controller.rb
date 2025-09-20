# frozen_string_literal: true

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
    @character = Character.new(character_params.except(:publish))
    @character.author = current_user
    authorize @character

    @character.published_at = Time.current if character_params[:publish] == "1"

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

    publish_flag = character_params[:publish]
    @character.published_at = (publish_flag == "1" ? Time.current : nil)

    if @character.update(character_params.except(:publish))
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
    params.require(:character).permit(:title, :body, :life_status, :birth_date, :death_date, :publish, :tags_string)
  end
end
