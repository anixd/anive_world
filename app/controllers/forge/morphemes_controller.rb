# frozen_string_literal: true

class Forge::MorphemesController < Forge::BaseController
  def search
    query = params[:query].to_s.strip
    language_id = params[:language_id]

    results = []

    if query.present? && language_id.present?
      if query.start_with?('-')
        # Ищем аффиксы, НЕ убирая дефис
        results = Affix.where(language_id: language_id)
                       .where('text ILIKE ?', "%#{query}%")
                       .limit(10)
                       .map { |a| { id: a.id, text: a.text, type: 'Affix' } }
      else
        # Ищем корни
        results = Root.where(language_id: language_id)
                      .where('text ILIKE ?', "%#{query}%")
                      .limit(10)
                      .map { |r| { id: r.id, text: r.text, type: 'Root' } }
      end
    end

    render json: results
  end
end
