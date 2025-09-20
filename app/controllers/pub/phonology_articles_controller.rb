# frozen_string_literal: true

class Pub::PhonologyArticlesController < Pub::BaseController
  def show
    @phonology_article = PhonologyArticle.published.find_by!(slug: params[:id])
  end
end
