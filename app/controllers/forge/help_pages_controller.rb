# frozen_string_literal: true

class Forge::HelpPagesController < Forge::BaseController
  before_action :set_help_page, only: %i[show edit update destroy]
  before_action :set_form_options, only: %i[new edit create update]

  def index
    @pagy, @help_pages = pagy(policy_scope(HelpPage).order(title: :asc))
  end

  def show
    authorize @help_page
  end

  def new
    @help_page = HelpPage.new
    authorize @help_page
  end

  def create
    @help_page = HelpPage.new(help_page_params)
    @help_page.author = current_user
    authorize @help_page

    if @help_page.save
      redirect_to forge_help_page_path(@help_page), notice: "Help page created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @help_page
  end

  def update
    authorize @help_page
    if @help_page.update(help_page_params)
      redirect_to forge_help_page_path(@help_page), notice: "Help page updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @help_page
    @help_page.discard
    redirect_to forge_help_pages_path, notice: "Help page archived."
  end

  private

  def set_help_page
    @help_page = policy_scope(HelpPage).find_by!(slug: params[:id])
  end

  def set_form_options
    @parent_options = HelpPage.order(:title).where.not(id: @help_page&.id)
  end

  def help_page_params
    params.require(:help_page).permit(:title, :body, :parent_location_id, :tags_string, :publish)
  end
end
