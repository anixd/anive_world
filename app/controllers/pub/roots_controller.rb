# frozen_string_literal: true

class Pub::RootsController < Pub::BaseController
  before_action :set_language

  def show
    @root = @language.roots.published.find_by!(slug: params[:id])
  end

  private

  def set_language
    @language = Language.kept.find(params[:language_id])
  end
end
