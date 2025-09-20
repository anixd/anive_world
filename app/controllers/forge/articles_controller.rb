# frozen_string_literal: true

class Forge::ArticlesController < Forge::BaseController
  before_action :set_article, only: %i[show edit update destroy]

  def index
    @pagy, @articles = pagy(policy_scope(Article).includes(:tags).order(created_at: :desc))
  end

  def show
    authorize @article
  end

  def new
    @article = Article.new
    authorize @article
  end

  def create
    @article = Article.new(article_params)
    @article.author = current_user
    authorize @article

    if @article.save
      redirect_to forge_article_path(@article), notice: "Article was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @article

    @backlinks = Wikilink.where(target_slug: @article.slug).includes(:source).limit(10)
  end

  def update
    authorize @article
    if @article.update(article_params)
      redirect_to forge_article_path(@article), notice: "Article was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @article
    @article.discard
    redirect_to forge_articles_path, notice: "Article was archived."
  end

  private

  def set_article
    @article = Article.includes(:tags).find_by!(slug: params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body, :publish, :tags_string)
  end
end
