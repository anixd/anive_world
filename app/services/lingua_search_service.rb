# frozen_string_literal: true

class LinguaSearchService
  # for searching within linguistic core
  attr_reader :query, :language_code, :mode

  def initialize(query:, language_code: nil, mode: :contains)
    @query = query.to_s.strip
    @language_code = language_code
    @mode = mode # :contains, :exact, :starts_with
  end

  def call
    return [] if @query.blank?

    results = []

    # Search in Lexemes
    lexemes = search_lexemes
    results.concat(format_results(lexemes, 'Lexeme'))

    # Search in Roots
    roots = search_roots
    results.concat(format_results(roots, 'Root'))

    # Search in Affixes
    affixes = search_affixes
    results.concat(format_results(affixes, 'Affix'))

    # Sort by relevance (exact matches first, then starts_with, then contains)
    sort_by_relevance(results)
  end

  private

  def search_lexemes
    scope = Lexeme.kept.includes(:language, words: :parts_of_speech)
    scope = apply_language_filter(scope) if @language_code.present?
    apply_search_mode(scope, :spelling)
  end

  def search_roots
    scope = Root.kept.includes(:language)
    scope = apply_language_filter(scope) if @language_code.present?
    apply_search_mode(scope, :text)
  end

  def search_affixes
    scope = Affix.kept.includes(:language)
    scope = apply_language_filter(scope) if @language_code.present?
    apply_search_mode(scope, :text)
  end

  def apply_language_filter(scope)
    if @language_code == 'any' || @language_code.nil?
      scope
    else
      scope.for_language(@language_code)
    end
  end

  def apply_search_mode(scope, field)
    case @mode
    when :exact
      scope.where(field => @query)
    when :starts_with
      scope.where("#{field} ILIKE ?", "#{@query}%")
    else # :contains
      scope.where("#{field} ILIKE ?", "%#{@query}%")
    end
  end

  def format_results(records, type)
    records.map do |record|
      {
        record: record,
        type: type,
        text: record.respond_to?(:spelling) ? record.spelling : record.text,
        language: record.language,
        relevance: calculate_relevance(record)
      }
    end
  end

  def calculate_relevance(record)
    text = record.respond_to?(:spelling) ? record.spelling : record.text
    return 100 if text.downcase == @query.downcase # Exact match
    return 75 if text.downcase.starts_with?(@query.downcase) # Starts with
    50 # Contains
  end

  def sort_by_relevance(results)
    results.sort_by { |r| -r[:relevance] }
  end
end
