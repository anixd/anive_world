class Forge::AffixesController < ApplicationController
  before_action :set_language_from_param, only: [:index]
  before_action :set_language_from_id, only: %i[new create edit update destroy]
  before_action :set_affix, only: %i[edit update destroy]

  def index
    @languages = Language.order(:name)
    scope = @language ? @language.affixes.includes(:author).order(:text) : Affix.none
    @pagy, @affixes = pagy(scope)
  end

  def new
    @affix = @language.affixes.build
  end

  def create
    @affix = @language.affixes.build(affix_params)
    @affix.author = current_user

    if @affix.save
      redirect_to forge_language_affixes_path(@language), notice: "Affix was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @affix.update(affix_params)
      redirect_to forge_language_affixes_path(@language), notice: "Affix was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @affix.discard
    redirect_to forge_language_affixes_path(@language), notice: "Affix was archived."
  end

  private

  def set_language_from_param
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @language = Language.find_by(code: target_code)
  end

  def set_language_from_id
    @language = Language.find(params[:language_id])
  end

  def set_affix
    @affix = @language.affixes.find(params[:id])
  end

  def affix_params
    params.require(:affix).permit(:text, :affix_type, :meaning)
  end
end
