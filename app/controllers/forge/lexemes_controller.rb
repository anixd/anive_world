class Forge::LexemesController < Forge::BaseController
  before_action :set_lexeme, only: [:show, :edit, :update, :destroy]
  before_action :set_form_options, only: [:new, :create, :edit, :update]

  def index
    @languages = Language.order(:name)
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @current_language = @languages.find { |l| l.code == target_code } || @languages.first

    scope = if @current_language
              Lexeme.where(language: @current_language)
                    .left_joins(:words)
                    .group('lexemes.id')
                    .order(spelling: :asc)
                    .select('lexemes.*, COUNT(words.id) AS words_count')
                    .preload(words: :parts_of_speech)
            else
              Lexeme.none
            end

    limit = params[:limit].present? ? params[:limit].to_i : Pagy::DEFAULT[:limit]
    @pagy, @lexemes = pagy(scope, limit: limit)
  end

  def show
    @words = @lexeme.words.includes(:etymology, :parts_of_speech).order(:created_at)
  end

  def new
    @lexeme = Lexeme.new
    @lexeme.words.build
  end

  def create
    @lexeme = Lexeme.new(lexeme_params)
    @lexeme.author = current_user

    @lexeme.words.first&.author = current_user

    if @lexeme.save
      redirect_to forge_lexeme_path(@lexeme), notice: "Слово '#{@lexeme.spelling}' создано."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @word.build_etymology if @word.etymology.nil?
  end

  def update
    updated_params = lexeme_params

    if updated_params[:words_attributes]
      updated_params[:words_attributes].each do |_, word_attrs|
        word_attrs[:author_id] = current_user.id
      end
    end

    if @lexeme.update(lexeme_params)
      redirect_to forge_lexeme_path(@lexeme), notice: "Лексема обновлена."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @lexeme.discard
    redirect_to forge_lexemes_path, notice: "Слово '#{@lexeme.spelling}' удалено."
  end

  private

  def set_lexeme
    @lexeme = Lexeme.includes(:language).find_by!(slug: params[:id])
  end

  def set_form_options
    @languages = Language.order(:name)
    @parts_of_speech = PartOfSpeech.order(:name)
  end

  def lexeme_params
    params.require(:lexeme).permit(
      :spelling, :language_id,
      words_attributes: [:id, :definition, :transcription, :comment, :_destroy, part_of_speech_ids: []]
    )
  end

  def word_params
    params.require(:lexeme).require(:words_attributes).require("0").permit(
:definition,
      :transcription,
      :comment,
      part_of_speech_ids: [],
      etymology_attributes: [:id, :explanation, :comment, :_destroy]
    )
  end
end
