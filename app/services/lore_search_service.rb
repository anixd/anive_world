# frozen_string_literal: true

class LoreSearchService
  # for searching within content entries

  # Content type prefixes mapping
  CONTENT_TYPE_PREFIXES = {
    'ar' => 'Article',
    'ch' => 'Character',
    'hs' => 'HistoryEntry',
    'lc' => 'Location',
    'gr' => 'GrammarRule',
    'ph' => 'PhonologyArticle'
  }.freeze

  # Language prefixes mapping
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

    # If we have a language prefix, always do dictionary search
    if @parsed_query[:language].present?
      return search_dictionary
    end

    # Check if scope is for dictionary
    if @scope.model == Lexeme
      return search_dictionary
    end

    # Regular content search for Lore
    filtered_scope = apply_filters(@scope)

    if filtered_scope.respond_to?(:search_by_text) && @parsed_query[:text].present?
      filtered_scope.search_by_text(@parsed_query[:text])
    else
      filtered_scope.none
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
      mode: :contains  # :contains, :exact, :starts_with
    }

    remaining_query = query.dup

    # Extract content type prefix (ar:, ch:, etc.)
    if remaining_query =~ /^(ar|ch|hs|lc|gr|ph):\s*/i
      prefix = $1.downcase
      result[:content_type] = CONTENT_TYPE_PREFIXES[prefix]
      remaining_query = remaining_query.sub(/^#{prefix}:\s*/i, '')
    end

    # Extract language prefix (an:, dr:, ve:, l:)
    if remaining_query =~ /^(an|dr|ve|l):\s*/i
      prefix = $1.downcase
      if prefix == 'l'
        result[:language] = 'any' # Special case for any language
      else
        result[:language] = LANGUAGE_PREFIXES[prefix]
      end
      remaining_query = remaining_query.sub(/^#{prefix}:\s*/i, '')
    end

    # Extract tags (#tag)
    tags = remaining_query.scan(/#(\w+)/).flatten
    result[:tags] = tags
    remaining_query = remaining_query.gsub(/#\w+/, '')

    # Extract exclusions (-word or !word)
    exclusions = remaining_query.scan(/[-!](\S+)/).flatten
    result[:exclusions] = exclusions
    remaining_query = remaining_query.gsub(/[-!]\S+/, '')

    # Check for exact match (quoted)
    if remaining_query =~ /^"([^"]+)"$/
      result[:mode] = :exact
      result[:text] = $1.strip
      # Check for starts with (^word)
    elsif remaining_query =~ /^\^(.+)$/
      result[:mode] = :starts_with
      result[:text] = $1.strip
    else
      result[:mode] = :contains
      result[:text] = remaining_query.strip
    end

    result
  end

  def search_dictionary
    # Use LinguaSearchService for unified dictionary search
    service = LinguaSearchService.new(
      query: @parsed_query[:text],
      language_code: @parsed_query[:language],
      mode: @parsed_query[:mode]
    )

    results = service.call

    # Return just the records as an array
    results.map { |r| r[:record] }
  end

  def apply_filters(scope)
    filtered = scope

    # Filter by content type if specified
    if @parsed_query[:content_type].present? && scope.model == ContentEntry
      filtered = filtered.where(type: @parsed_query[:content_type])
    end

    # Filter by tags if specified
    if @parsed_query[:tags].any? && filtered.respond_to?(:joins)
      @parsed_query[:tags].each do |tag_name|
        filtered = filtered.joins(:tags).where(tags: { name: tag_name })
      end
    end

    # TODO: Apply exclusions filter
    # This is more complex and needs proper implementation

    filtered
  end
end
