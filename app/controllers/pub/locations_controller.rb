# frozen_string_literal: true

class Pub::LocationsController < Pub::BaseController
  def index
    locations = Location.published.order(title: :asc)
    @pagy, @locations = pagy(locations)
  end

  def show
    @location = Location.published.find_by!(slug: params[:id])
  end
end
