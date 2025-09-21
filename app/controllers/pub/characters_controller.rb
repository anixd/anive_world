# frozen_string_literal: true

class Pub::CharactersController < Pub::BaseController
  def index
    characters = Character.published.order(title: :asc)
    @pagy, @characters = pagy(characters)
  end

  def show
    @character = Character.published.find_by!(slug: params[:id])
  end
end
