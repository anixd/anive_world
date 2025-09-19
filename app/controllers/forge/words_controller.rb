# frozen_string_literal: true

class Forge::WordsController < Forge::BaseController
  before_action :set_lexeme, only: [:new, :create]
  before_action :set_word, only: [:edit, :update, :destroy]
  before_action :set_form_options, only: [:new, :create, :edit, :update]

  def new
    @word = @lexeme.words.build
    @word.build_etymology
    authorize @word
  end

  def create
    @word = @lexeme.words.build(word_params)
    @word.author = current_user

    if @word.etymology.present?
      @word.etymology.author = current_user
    end

    authorize @word

    if @word.save
      redirect_to forge_lexeme_path(@lexeme), notice: "Meaning was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @word
    @word.build_etymology if @word.etymology.nil?
  end

  def update
    authorize @word
    attributes = word_params

    etymology_attrs = attributes[:etymology_attributes]
    if etymology_attrs.present? && etymology_attrs[:id].blank?
      etymology_attrs.merge!(author: current_user)
    end

    if @word.update(attributes)
      redirect_to forge_lexeme_path(@word.lexeme), notice: "Meaning was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @word
    lexeme = @word.lexeme
    @word.discard
    redirect_to forge_lexeme_path(lexeme), notice: "Meaning was deleted."
  end

  def search
    query = params[:query].to_s.strip
    except_id = params[:except_id]

    # Начинаем запрос, сразу объединяя с Lexeme для поиска по написанию
    scope = Word.joins(:lexeme)

    # Применяем фильтр по тексту, если он есть
    scope = scope.where("lexemes.spelling ILIKE ?", "%#{query}%") if query.present?

    # Исключаем текущее слово из результатов, чтобы оно не стало предком само себе
    scope = scope.where.not(id: except_id) if except_id.present?

    words = scope.limit(10)

    render json: words.map { |word| { id: word.id, text: word.spelling_with_language } }
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
      :origin_type,
      :origin_word_id,
      part_of_speech_ids: [],
      etymology_attributes: [:id, :explanation, :comment, :_destroy])
  end
end
