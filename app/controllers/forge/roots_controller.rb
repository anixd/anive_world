class Forge::RootsController < Forge::BaseController
  before_action :set_language_from_id, except: [:index]
  before_action :set_root, only: %i[edit update destroy]

  def index
    @languages = Language.order(:name)
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @current_language = @languages.find { |l| l.code == target_code } || Language.order(:name).first

    scope = if @current_language
              @current_language.roots.includes(:author).order(:text)
            else
              Root.none
            end

    @pagy, @roots = pagy(policy_scope(scope))
  end

  def new
    @root = @language.roots.build
    @root.build_etymology
    authorize @root
  end

  def create
    @root = @language.affixes.build(root_params)
    @affix.author = current_user
    authorize @root

    if @root.etymology.present?
      @root.etymology.author = current_user
    end

    if @root.save
      redirect_to forge_language_affixes_path(@language, lang: @language.code), notice: "Affix was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @root
    @root.build_etymology if @root.etymology.nil?
  end

  def update
    authorize @root
    @root.assign_attributes(root_params)

    if @root.etymology.present? && @root.etymology.new_record?
      @root.etymology.author = current_user
    end

    if @root.save
      redirect_to forge_language_affixes_path(@language, lang: @language.code), notice: "Affix was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @root
    @root.discard
    redirect_to forge_language_roots_path(@language, lang: @language.code), notice: "Root was archived."
  end

  private

  # Этот метод находит родительский язык по :language_id из URL
  def set_language_from_id
    @language = Language.find(params[:language_id])
  end

  def set_root
    # Теперь @language гарантированно будет установлен из set_language_from_id
    @root = @language.roots.find(params[:id])
  end

  def root_params
    params.require(:root).permit(
      :text, :meaning,
      etymology_attributes: [:id, :explanation, :comment]
    )
  end
end