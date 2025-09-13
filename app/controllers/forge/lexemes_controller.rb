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
    # Применяем policy_scope к уже отфильтрованной коллекции
    @pagy, @lexemes = pagy(policy_scope(scope), limit: limit)
  end

  def show
    authorize @lexeme # Can view?
    @words = @lexeme.words.includes(:etymology, :parts_of_speech).order(:created_at)
  end

  def new
    @lexeme = Lexeme.new
    @lexeme.words.build
    authorize @lexeme # Can create?
  end

  def create
    @lexeme = Lexeme.new(lexeme_params)
    @lexeme.author = current_user
    @lexeme.words.first&.author = current_user
    authorize @lexeme # Can create?

    if @lexeme.save
      redirect_to forge_lexeme_path(@lexeme), notice: "Слово '#{@lexeme.spelling}' создано."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @lexeme # Can edit?
  end

  def update
    authorize @lexeme # Can update?

    # ... (остальная логика метода без изменений)
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
    authorize @lexeme # Can destroy?
    @lexeme.discard
    redirect_to forge_lexemes_path, notice: "Слово '#{@lexeme.spelling}' удалено."
  end

  private

  def set_lexeme
    # Мы находим лексему по slug, а не по id
    @lexeme = Lexeme.includes(:language).find_by!(slug: params[:id])
  end

  def set_form_options
    @languages = Language.order(:name)
    # Здесь мы не можем просто взять все, нужно будет фильтровать во вьюхе/JS
    @parts_of_speech = PartOfSpeech.order(:name)
  end

  def lexeme_params
    params.require(:lexeme).permit(
      :spelling, :language_id,
      words_attributes: [:id, :definition, :transcription, :comment, :_destroy, part_of_speech_ids: []]
    )
  end
end
