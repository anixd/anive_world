# frozen_string_literal: true

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
                    .group("lexemes.id")
                    .order(spelling: :asc)
                    .select("lexemes.*, COUNT(words.id) AS words_count")
                    .preload(words: :parts_of_speech)
            else
              Lexeme.none
            end

    limit = params[:limit].present? ? params[:limit].to_i : Pagy::DEFAULT[:limit]
    @pagy, @lexemes = pagy(policy_scope(scope), limit: limit)
  end

  def show
    authorize @lexeme
    @words = @lexeme.words.includes(:etymology, :parts_of_speech).order(:created_at)
  end

  def new
    @lexeme = Lexeme.new

    if params.dig(:lexeme, :language_id).present?
      @lexeme.language_id = params.dig(:lexeme, :language_id)
    end

    @lexeme.words.build
    authorize @lexeme
  end

  def create
    attrs = lexeme_params.to_h
    publish_flag = attrs.delete(:publish)

    @lexeme = Lexeme.new(attrs)
    @lexeme.author = current_user
    @lexeme.words.first&.author = current_user
    authorize @lexeme

    @lexeme.published_at = Time.current if publish_flag == '1'

    if @lexeme.save
      redirect_to forge_lexeme_path(@lexeme), notice: "Слово '#{@lexeme.spelling}' создано."
    else
      set_form_options
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @lexeme
  end

  def update
    authorize @lexeme

    attrs = lexeme_params.to_h
    publish_flag = attrs.delete(:publish)

    @lexeme.assign_attributes(attrs)
    @lexeme.published_at = (publish_flag == '1') ? Time.current : nil

    if @lexeme.save
      redirect_to forge_lexeme_path(@lexeme), notice: "Лексема обновлена."
    else
      set_form_options
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @lexeme
    @lexeme.discard
    redirect_to forge_lexemes_path, notice: "Слово '#{@lexeme.spelling}' удалено."
  end

  def parts_of_speech
    language = Language.find_by(id: params[:language_id])
    @parts_of_speech = language ? language.parts_of_speech.order(:name) : []

    @lexeme = Lexeme.new(language: language)
    @lexeme.words.build

    respond_to do |format|
      format.turbo_stream
    end
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
      :spelling, :language_id, :publish,
      words_attributes: [:id, :definition, :transcription, :comment, :_destroy, part_of_speech_ids: []]
    )
  end
end
