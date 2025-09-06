class Forge::LanguagesController < Forge::BaseController
  before_action :set_language, only: %i[show edit update destroy]
  before_action :set_form_options, only: %i[new edit create update]

  def index
    @languages = Language.includes(:parent_language, :child_languages).order(:name)
  end

  def show
  end

  def new
    @language = Language.new
  end

  def edit
  end

  def create
    @language = Language.new(language_params)
    @language.author = current_user

    if @language.save
      redirect_to forge_language_path(@language), notice: "Язык '#{@language.name}' создан."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @language.update(language_params)
      redirect_to forge_language_path(@language), notice: "Язык '#{@language.name}' обновлен."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @language.discard
    redirect_to forge_languages_path, notice: "Язык '#{@language.name}' был удален (архивирован)."
  end

  private

  def set_language
    @language = Language.includes(:parent_language, :child_languages, :author).find(params[:id])
  end

  def set_form_options
    # Загружаем список языков для выпадающего списка "родительский язык"
    # Исключаем текущий язык из списка, чтобы он не мог стать родителем сам себе
    @parent_language_options = Language.where.not(id: @language&.id).order(:name)
  end

  def language_params
    params.require(:language).permit(:name, :code, :description, :parent_language_id)
  end
end
