# frozen_string_literal: true

class Forge::PhonologyArticlesController < Forge::BaseController
  before_action :set_phonology_article, only: %i[show edit update destroy]
  before_action :set_form_options, only: %i[new edit create update]

  def index
    @languages = Language.order(:name)
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @current_language = @languages.find { |l| l.code == target_code } || @languages.first

    scope = if @current_language
              policy_scope(PhonologyArticle).includes(:tags).where(language_id: @current_language.id).order(title: :asc)
            else
              PhonologyArticle.none
            end
    @pagy, @phonology_articles = pagy(scope)
  end

  def show
    authorize @phonology_article
  end

  def new
    @phonology_article = PhonologyArticle.new
    authorize @phonology_article
  end

  def create
    @phonology_article = PhonologyArticle.new(phonology_article_params)
    @phonology_article.author = current_user
    authorize @phonology_article

    if @phonology_article.save
      redirect_to forge_phonology_article_path(@phonology_article), notice: "Phonology was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @phonology_article
  end

  def update
    authorize @phonology_article
    if @phonology_article.update(phonology_article_params)
      redirect_to forge_phonology_article_path(@phonology_article), notice: "Phonology was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @phonology_article
    @phonology_article.discard
    redirect_to forge_phonology_articles_path, notice: "Phonology was archived."
  end

  private

  def set_phonology_article
    @phonology_article = PhonologyArticle.includes(:tags).find_by!(slug: params[:id])
  end

  def set_form_options
    @languages = Language.order(:name)
  end

  def phonology_article_params
    params.require(:phonology_article).permit(
      :title, :body, :language_id, :rule_code, :tags_string, :publish, :annotation, :extract
    )
  end
end
