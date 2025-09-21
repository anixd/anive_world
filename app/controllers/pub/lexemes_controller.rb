# frozen_string_literal: true

class Pub::LexemesController < Pub::BaseController
  before_action :set_language
  before_action :set_lexeme, only: [:show]

  def index
    # части речи для текущего языка (для формы с фильтрами)
    @parts_of_speech = @language.parts_of_speech.order(:name)

    # Базовый запрос
    lexemes = @language.lexemes.published
                       .includes(words: :parts_of_speech)
                       .order(:spelling)

    # коды частей речи из URL, отсекаем пустые значения
    selected_pos_codes = params[:pos]&.reject(&:blank?)

    # Если фильтры выбраны, применяем их
    if selected_pos_codes.present?
      lexemes = lexemes.joins(words: :parts_of_speech)
                       .where(parts_of_speech: { code: selected_pos_codes })
                       .distinct
    end

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
