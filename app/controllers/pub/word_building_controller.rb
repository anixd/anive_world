# frozen_string_literal: true

class Pub::WordBuildingController < Pub::BaseController
  before_action :set_language

  def index
    @active_tab = params.fetch(:tab, "roots")

    @affix_categories = @language.affix_categories.order(:name)

    if @active_tab == "affixes"
      affixes = @language.affixes.published.includes(:affix_category).order(:text)

      if params[:category_id].present?
        affixes = affixes.where(affix_category_id: params[:category_id])
      end

      @pagy, @affixes = pagy(affixes, limit: 50, page_param: :page_affixes)
    else
      roots = @language.roots.published.order(:text)
      @pagy, @roots = pagy(roots, limit: 50, page_param: :page_roots)
    end
  end

  private

  def set_language
    @language = Language.kept.find(params[:language_id])
  end
end
