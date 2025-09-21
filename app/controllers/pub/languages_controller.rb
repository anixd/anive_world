# frozen_string_literal: true

class Pub::LanguagesController < Pub::BaseController

  def index
    @languages = Language.kept.order(:name)
  end

  def show
    @language = Language.kept.find(params[:id])
  end
end
