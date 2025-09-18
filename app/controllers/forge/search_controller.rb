# frozen_string_literal: true

class Forge::SearchController < Forge::BaseController
  def index
    @query = params[:q].to_s.strip
    @scope_name = params[:scope] || 'lore'

    return render_empty_results if @query.blank?

    # Parse query for prefixes and filters
    search_service = LoreSearchService.new(
      scope: base_scope_for(@scope_name),
      query_string: @query
    )

    results = search_service.call

    # Handle both ActiveRecord::Relation and Array results
    if results.is_a?(Array)
      @pagy, @results = pagy_array(results, items: 20)
    else
      @pagy, @results = pagy(results, items: 20)
    end

    respond_to do |format|
      format.html
      format.turbo_stream { render_live_search }
    end
  end

  private

  def determine_actual_scope(query, default_scope_name)
    # Check for language prefixes that force dictionary search
    if query =~ /^(an|dr|ve|l):\s*/i
      # Language prefix found - force dictionary scope
      policy_scope(Lexeme).includes(:language, words: :parts_of_speech)
    else
      # No language prefix - use tab selection
      base_scope_for(default_scope_name)
    end
  end

  def base_scope_for(scope_name)
    case scope_name
    when 'lingua', 'dictionary'
      # For dictionary search
      policy_scope(Lexeme).includes(:language, words: :parts_of_speech)
    else # 'lore'
      # For lore search - search in ContentEntry
      policy_scope(ContentEntry).kept
    end
  end

  def render_empty_results
    @results = []
    @pagy = Pagy.new(count: 0, page: 1)

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream { render_live_search }
    end
  end

  def render_live_search
    # Only show first 5 results for live search dropdown
    @live_results = if @results.is_a?(Array)
                      @results.first(5)
                    else
                      @results.limit(5)
                    end
    render :live_search
  end
end
