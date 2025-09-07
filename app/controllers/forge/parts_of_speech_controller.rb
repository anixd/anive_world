class Forge::PartsOfSpeechController < Forge::BaseController

  before_action :set_language_from_id, only: %i[new create edit update destroy]
  before_action :set_part_of_speech, only: %i[edit update destroy]

  def index
    @languages = Language.order(:name)
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @current_language = @languages.find { |l| l.code == target_code } || Language.order(:name).first

    scope = if @current_language
              @current_language.parts_of_speech.order(:name)
            else
              PartOfSpeech.none
            end
    @parts_of_speech = scope
  end

  def new
    @part_of_speech = @language.parts_of_speech.build
  end

  def create
    @part_of_speech = @language.parts_of_speech.build(part_of_speech_params)
    @part_of_speech.author = current_user

    if @part_of_speech.save
      redirect_to forge_language_parts_of_speech_path(@language), notice: "Part of speech was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @part_of_speech.update(part_of_speech_params)
      redirect_to forge_language_parts_of_speech_path(@language), notice: "Part of speech was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @part_of_speech.discard
    redirect_to forge_language_parts_of_speech_path(@language), notice: "Part of speech was archived."
  end

  private

  def set_language_from_id
    @language = Language.find(params[:language_id])
  end

  def set_language
    @language = Language.find(params[:language_id])
  end

  def set_part_of_speech
    @part_of_speech = @language.parts_of_speech.find(params[:id])
  end

  def part_of_speech_params
    params.require(:part_of_speech).permit(:name, :code, :explanation)
  end
end
