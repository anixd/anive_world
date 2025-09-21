# frozen_string_literal: true

class Pub::AffixesController < Pub::BaseController
  before_action :set_language

  def show
    @affix = @language.affixes.published.find_by!(slug: params[:id])
  end

  private

  def set_language
    @language = Language.kept.find(params[:language_id])
  end
end
