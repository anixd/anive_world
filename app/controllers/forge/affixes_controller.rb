class Forge::AffixesController < Forge::BaseController
  before_action :set_language_from_id, except: [:index]
  before_action :set_affix, only: %i[edit update destroy]

  def index
    @languages = Language.order(:name)
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @current_language = @languages.find { |l| l.code == target_code } || Language.order(:name).first

    scope = if @current_language
              @current_language.affixes.includes(:author).order(:text)
            else
              Affix.none
            end

    @pagy, @affixes = pagy(scope)
  end

  def new
    @affix = @language.affixes.build
    @affix.build_etymology
  end

  def create
    @affix = @language.affixes.build(affix_params)
    @affix.author = current_user

    if @affix.etymology.present?
      @affix.etymology.author = current_user
    end

    if @affix.save
      redirect_to forge_language_affixes_path(@language, lang: @language.code), notice: "Affix was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @affix.build_etymology if @affix.etymology.nil?
  end

  def update
    @affix.assign_attributes(affix_params)

    if @affix.etymology.present? && @affix.etymology.new_record?
      @affix.etymology.author = current_user
    end

    if @affix.save
      redirect_to forge_language_affixes_path(@language, lang: @language.code), notice: "Affix was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @affix.discard
    redirect_to forge_language_affixes_path(@language, lang: @language.code), notice: "Affix was archived."
  end

  private

  def set_language_from_id
    @language = Language.find(params[:language_id])
  end

  def set_affix
    @affix = @language.affixes.find(params[:id])
  end

  def affix_params
    params.require(:affix).permit(
      :text, :affix_type, :meaning,
      etymology_attributes: [:id, :explanation, :comment]
    )
  end
end
