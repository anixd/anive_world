# frozen_string_literal: true

class Pub::HelpPagesController < Pub::BaseController
  def index
    @help_pages = HelpPage.published.top_level.order(:title)
  end

  def show
    @help_page = HelpPage.published.includes(:children).find_by!(slug: params[:id])
  end
end
