# frozen_string_literal: true

class Pub::LexemesController < Pub::BaseController
  before_action :set_language
  before_action :set_lexeme, only: [:show]

  def index
    lexemes = @language.lexemes.published
                       .includes(words: :parts_of_speech)
                       .order(:spelling)

    @pagy, @lexemes = pagy(lexemes, limit: per_page)
  end

  def show
    @words = @lexeme.words.includes(:etymology, :parts_of_speech).order(:created_at)
  end

  private

  def set_lexeme
    @lexeme = Lexeme.includes(:language).find_by!(slug: params[:id])
  end

  def set_language
    @language = Language.kept.find(params[:language_id])
  end
end
