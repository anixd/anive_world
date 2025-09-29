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

    @lexeme.words.build.build_etymology

    authorize @lexeme
  end

  def create
    attrs = lexeme_params.to_h
    morphemes_data = attrs.delete(:morphemes_list)
    morphemes_list = morphemes_data.present? ? JSON.parse(morphemes_data, symbolize_names: true) : []

    @lexeme = Lexeme.new(attrs)
    @lexeme.author = current_user
    @lexeme.words.first&.author = current_user
    authorize @lexeme

    begin
      ActiveRecord::Base.transaction do
        @lexeme.save!
        update_morphemes(morphemes_list)
      end
      redirect_to forge_lexeme_path(@lexeme), notice: "Lexeme '#{@lexeme.spelling}' was successfully created."
    rescue ActiveRecord::RecordInvalid
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
    morphemes_data = attrs.delete(:morphemes_list)
    morphemes_list = morphemes_data.present? ? JSON.parse(morphemes_data, symbolize_names: true) : []

    @lexeme.assign_attributes(attrs)

    begin
      ActiveRecord::Base.transaction do
        @lexeme.save!
        update_morphemes(morphemes_list)
      end
      redirect_to forge_lexeme_path(@lexeme), notice: "Lexeme was successfully updated."
    rescue ActiveRecord::RecordInvalid
      set_form_options
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @lexeme
    @lexeme.discard
    redirect_to forge_lexemes_path, notice: "Lexeme '#{@lexeme.spelling}' was successfully archived."
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
    @lexeme = Lexeme.includes(:language, morphemes: :morphemable).find_by!(slug: params[:id])
  end

  def set_form_options
    @languages = Language.order(:name)
    @parts_of_speech = PartOfSpeech.order(:name)
  end

  def update_morphemes(list)
    @lexeme.morphemes.destroy_all
    return if list.blank?

    morphemes_to_create = list.map do |m_data|
      {
        lexeme_id: @lexeme.id,
        morphemable_id: m_data[:id],
        morphemable_type: m_data[:type],
        position: m_data[:position]
      }
    end

    Morpheme.insert_all(morphemes_to_create) if morphemes_to_create.any?
  end

  def lexeme_params
    params.require(:lexeme).permit(
      :spelling,
      :language_id,
      :publish,
      :morphemes_list,
      :origin_type,
      :origin_language_id,
      words_attributes: [:id, :definition, :transcription, :comment, :_destroy, part_of_speech_ids: []],
      etymology_attributes: [:id, :explanation, :comment, :_destroy]
    )
  end
end
