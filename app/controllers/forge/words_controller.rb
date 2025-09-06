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
      redirect_to forge_lexeme_path(@lexeme), notice: "Новое значение добавлено."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @word.update(word_params)
      redirect_to forge_lexeme_path(@word.lexeme), notice: "Значение обновлено."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    lexeme = @word.lexeme
    @word.discard
    redirect_to forge_lexeme_path(lexeme), notice: "Значение удалено."
  end

  private

  def set_lexeme
    @lexeme = Lexeme.find_by!(slug: params[:lexeme_id])
  end

  def set_word
    @word = Word.includes(:lexeme).find(params[:id])
  end

  def set_form_options
    # Устанавливаем язык из лексемы для редактирования или из родительской лексемы для нового
    language = @word&.language || @lexeme.language
    # Загружаем части речи ТОЛЬКО для этого языка
    @parts_of_speech = PartOfSpeech.where(language: language).order(:name)
  end

  def word_params
    params.require(:word).permit(:definition, :transcription, :comment, :part_of_speech_id)
  end
end
