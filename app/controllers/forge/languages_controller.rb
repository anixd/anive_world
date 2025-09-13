class Forge::LanguagesController < Forge::BaseController
  before_action :set_language, only: %i[show edit update destroy]
  before_action :set_form_options, only: %i[new edit create update]

  def index
    # policy_scope уже здесь, он фильтрует коллекцию
    @languages = policy_scope(Language).includes(:parent_language, :child_languages).order(:name)
  end

  def show
    # Проверяем, может ли user просматривать @language?
    # Pundit вызовет LanguagePolicy#show?
    authorize @language
  end

  def new
    # Создаем новый, "пустой" язык
    @language = Language.new
    # Проверяем, имеет ли user право создавать языки?
    # Pundit вызовет LanguagePolicy#new? (который делегирует в #create?)
    authorize @language
  end

  def edit
    # @language уже найден before_action'ом
    # Проверяем, может ли user редактировать @language?
    # Pundit вызовет LanguagePolicy#edit? (который делегирует в #update?)
    authorize @language
  end

  def create
    @language = Language.new(language_params)
    @language.author = current_user
    # Проверяем, имеет ли user право создавать языки?
    # Pundit вызовет LanguagePolicy#create?
    authorize @language

    if @language.save
      redirect_to forge_language_path(@language), notice: "Язык '#{@language.name}' создан."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    # @language уже найден before_action'ом
    # Проверяем, может ли user обновлять @language?
    # Pundit вызовет LanguagePolicy#update?
    authorize @language

    if @language.update(language_params)
      redirect_to forge_language_path(@language), notice: "Язык '#{@language.name}' обновлен."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    # @language уже найден before_action'ом
    # Проверяем, может ли user удалять @language?
    # Pundit вызовет LanguagePolicy#destroy?
    authorize @language

    @language.discard
    redirect_to forge_languages_path, notice: "Язык '#{@language.name}' был удален (архивирован)."
  end

  private

  def set_language
    # Находим язык и сразу же его авторизуем.
    # Это хороший паттерн, но для ясности оставим `authorize` в каждом экшене.
    @language = Language.includes(:parent_language, :child_languages, :author).find(params[:id])
  end

  def set_form_options
    @parent_language_options = Language.where.not(id: @language&.id).order(:name)
  end

  def language_params
    params.require(:language).permit(:name, :code, :description, :parent_language_id)
  end
end
