# frozen_string_literal: true

class Pub::WordBuildingController < Pub::BaseController
  before_action :set_language

  def index
    @active_tab = params.fetch(:tab, "roots")

    if @active_tab == "affixes"
      affixes = @language.affixes.published.order(:text)
      @pagy, @affixes = pagy(affixes, limit: 25, page_param: :page_affixes)
    else # По умолчанию 'roots'
      roots = @language.roots.published.order(:text)
      @pagy, @roots = pagy(roots, limit: 25, page_param: :page_roots)
    end
  end

  private

  def set_language
    @language = Language.kept.find(params[:language_id])
  end
end
