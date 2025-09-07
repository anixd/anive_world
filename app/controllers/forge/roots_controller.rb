class Forge::RootsController < Forge::BaseController

  before_action :set_language, only: %i[index new create]
  before_action :set_root, only: %i[edit update destroy]

  def index
    @languages = Language.order(:name)
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @current_language = @languages.find { |l| l.code == target_code } || Language.find_by(code: Language::DEFAULT_CODE) || @languages.first

    scope = if @current_language
              # Eager loading для :author, чтобы избежать N+1 запросов
              Root.where(language: @current_language).includes(:author).order(:text)
            else
              Root.none
            end

    @pagy, @roots = pagy(scope, limit: per_page)
  end

  def new
    @root = @language.roots.build
  end

  def create
    @root = @language.roots.build(root_params)
    @root.author = current_user

    if @root.save
      redirect_to forge_language_roots_path(@language), notice: "Root was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @root.update(root_params)
      redirect_to forge_language_roots_path(@language), notice: "Root was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @root.discard
    redirect_to forge_language_roots_path(@language), notice: "Root was archived."
  end

  private

  def set_language
    if params[:language_id]
      @language = Language.find(params[:language_id])
    end
  end

  def set_root
    @root = @language.roots.find(params[:id])
  end

  def root_params
    params.require(:root).permit(:text, :meaning)
  end
end
