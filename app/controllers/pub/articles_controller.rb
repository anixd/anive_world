# frozen_string_literal: true

class Pub::ArticlesController < Pub::BaseController
  def index
    published_articles = Article.published.order(published_at: :desc)
    @pagy, @articles = pagy(published_articles)
  end

  def show
    @article = Article.published.find_by!(slug: params[:id])
  end
end