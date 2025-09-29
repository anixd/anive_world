# frozen_string_literal: true

class Forge::AffixCategoriesController < Forge::BaseController
  before_action :set_language_from_id
  before_action :set_affix_category, only: %i[edit update destroy]

  def index
    @affix_categories = policy_scope(@language.affix_categories).order(:name)
  end

  def new
    @affix_category = @language.affix_categories.build
    authorize @affix_category
  end

  def create
    @affix_category = @language.affix_categories.build(affix_category_params)
    @affix_category.author = current_user
    authorize @affix_category

    if @affix_category.save
      redirect_to forge_language_affix_categories_path(@language), notice: "Affix category was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @affix_category
  end

  def update
    authorize @affix_category
    if @affix_category.update(affix_category_params)
      redirect_to forge_language_affix_categories_path(@language), notice: "Affix category was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @affix_category
    @affix_category.destroy
    redirect_to forge_language_affix_categories_path(@language), notice: "Affix category was destroyed."
  end

  private

  def set_language_from_id
    @language = Language.find(params[:language_id])
  end

  def set_affix_category
    @affix_category = @language.affix_categories.find(params[:id])
  end

  def affix_category_params
    params.require(:affix_category).permit(:name, :description)
  end
end
