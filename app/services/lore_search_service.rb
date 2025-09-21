# frozen_string_literal: true

class LoreSearchService
  CONTENT_TYPE_PREFIXES = {
    'ar' => 'Article',
    'ch' => 'Character',
    'hs' => 'HistoryEntry',
    'lc' => 'Location',
    'gr' => 'GrammarRule',
    'ph' => 'PhonologyArticle'
  }.freeze

  LANGUAGE_PREFIXES = {
    'an' => 'anike',
    'dr' => 'drelen',
    've' => 'veltari'
  }.freeze

  attr_reader :scope, :query_string, :parsed_query

  def initialize(scope:, query_string: nil)
    @scope = scope
    @query_string = query_string.to_s.strip
    @parsed_query = parse_query(@query_string)
  end

  def call
    return @scope.none if @query_string.blank?

    if @parsed_query[:language].present?
      return search_dictionary
    end

    if @scope.model == Lexeme
      return search_dictionary
    end

    filtered_scope = apply_filters(@scope)

    # Теперь в @parsed_query[:text] уже будет строка вида "текст !исключение"
    if filtered_scope.respond_to?(:search_by_text) && @parsed_query[:text].present?
      filtered_scope.search_by_text(@parsed_query[:text]).with_pg_search_rank
    else
      # Если после парсинга текста не осталось (например, был только тег),
      # возвращаем отфильтрованный по префиксам/тегам скоуп.
      filtered_scope
    end
  end

  private

  def parse_query(query)
    result = {
      text: '',
      content_type: nil,
      language: nil,
      tags: [],
      exclusions: [],
      mode: :contains
    }

    remaining_query = query.dup

    if remaining_query =~ /^(ar|ch|hs|lc|gr|ph):\s*/i
      prefix = $1.downcase
      result[:content_type] = CONTENT_TYPE_PREFIXES[prefix]
      remaining_query = remaining_query.sub(/^#{prefix}:\s*/i, '')
    end

    if remaining_query =~ /^(an|dr|ve|l):\s*/i
      prefix = $1.downcase
      result[:language] = (prefix == 'l') ? 'any' : LANGUAGE_PREFIXES[prefix]
      remaining_query = remaining_query.sub(/^#{prefix}:\s*/i, '')
    end

    tag_regex = /#([a-zA-Z0-9\-_']+)/
    tags = remaining_query.scan(tag_regex).flatten
    result[:tags] = tags
    remaining_query = remaining_query.gsub(tag_regex, '')

    exclusions = remaining_query.scan(/!(\S+)/).flatten
    result[:exclusions] = exclusions
    remaining_query = remaining_query.gsub(/!\S+/, '')

    # логика определения режима поиска
    if remaining_query =~ /^"([^"]+)"$/
      result[:mode] = :exact
      result[:text] = $1.strip
    elsif remaining_query =~ /^\^(.+)$/
      result[:mode] = :starts_with
      result[:text] = $1.strip
    else
      result[:mode] = :contains
      result[:text] = remaining_query.strip
    end

    if result[:exclusions].any?
      exclusion_string = result[:exclusions].map { |ex| "!#{ex}" }.join(' ')
      result[:text] = [result[:text], exclusion_string].reject(&:blank?).join(' ')
    end

    result
  end

  def search_dictionary
    service = LinguaSearchService.new(
      query: @parsed_query[:text],
      language_code: @parsed_query[:language],
      mode: @parsed_query[:mode]
    )

    results = service.call
    results.map { |r| r[:record] }
  end

  def apply_filters(scope)
    filtered = scope

    if @parsed_query[:content_type].present? && scope.model == ContentEntry
      filtered = filtered.where(type: @parsed_query[:content_type])
    end

    if @parsed_query[:tags].any? && filtered.respond_to?(:joins)
      @parsed_query[:tags].each do |tag_name|
        # Используем `distinct`, чтобы избежать дубликатов, если у записи несколько тегов
        filtered = filtered.joins(:tags).where(tags: { name: tag_name }).distinct
      end
    end

    filtered
  end
end