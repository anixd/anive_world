# frozen_string_literal: true

class Pub::GrammarController < Pub::BaseController
  before_action :set_language

  def index
    @active_tab = params.fetch(:tab, "grammar")

    if @active_tab == "phonology"
      articles = ContentEntry.where(language_id: @language.id, type: "PhonologyArticle")
                             .published
                             .order(:title)
      @pagy, @items = pagy(articles, limit: 25, page_param: :page_phonology)
    else
      rules = ContentEntry.where(language_id: @language.id, type: "GrammarRule")
                          .published
                          .order(:title)
      @pagy, @items = pagy(rules, limit: 25, page_param: :page_grammar)
    end
  end

  private

  def set_language
    @language = Language.kept.find(params[:language_id])
  end
end
