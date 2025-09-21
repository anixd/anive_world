# frozen_string_literal: true

class Pub::LocationsController < Pub::BaseController
  def index
    locations = Location.published.includes(:tags).order(title: :asc)
    @pagy, @locations = pagy(locations)
  end

  def show
    @location = Location.published.includes(:tags).find_by!(slug: params[:id])
  end
end
