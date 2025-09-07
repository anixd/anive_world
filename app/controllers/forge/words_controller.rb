class Forge::WordsController < Forge::BaseController
  before_action :set_lexeme, only: [:new, :create]
  before_action :set_word, only: [:edit, :update, :destroy]
  before_action :set_form_options, only: [:new, :create, :edit, :update]

  def new
    @word = @lexeme.words.build
  end

  def create
    @word = @lexeme.words.build(word_params)
    @word.author = current_user

    if @word.save
      redirect_to forge_lexeme_path(@lexeme), notice: "Etymology was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @word.build_etymology if @word.etymology.nil?
  end

  def update
    attributes = word_params

    etymology_attrs = attributes[:etymology_attributes]
    if etymology_attrs.present? && etymology_attrs[:id].blank?
      etymology_attrs.merge!(author: current_user)
    end

    if @word.update(attributes)
      redirect_to forge_lexeme_path(@word.lexeme), notice: "Etymology was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    lexeme = @word.lexeme
    @word.discard
    redirect_to forge_lexeme_path(lexeme), notice: "Etymology was deleted."
  end

  private

  def set_lexeme
    @lexeme = Lexeme.find_by!(slug: params[:lexeme_id])
  end

  def set_word
    @word = Word.includes(:lexeme).find(params[:id])
  end

  def set_form_options
    language = @word&.language || @lexeme.language
    @parts_of_speech = PartOfSpeech.where(language: language).order(:name)
  end

  def word_params
    params.require(:word).permit(
      :definition,
             :transcription,
             :comment,
             part_of_speech_ids: [],
             etymology_attributes: [:id, :explanation, :comment, :_destroy])
  end
end
