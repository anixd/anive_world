# frozen_string_literal: true

class Pub::SearchController < Pub::BaseController
  def index
    @query = params[:q].to_s.strip
    @scope_name = params.fetch(:scope, "lore")

    if @query.blank?
      @results = []
      @pagy = Pagy.new(count: 0, page: 1)
      return
    end

    base_scope = if @scope_name == "dictionary"
                   # eager-loading для языка, чтобы избежать N+1
                   Lexeme.published.includes(:language)
                 else
                   ContentEntry.published
                 end

    search_service = LoreSearchService.new(
      scope: base_scope,
      query_string: @query
    )

    results = search_service.call
    @pagy, @results = results.is_a?(Array) ? pagy_array(results) : pagy(results)

    respond_to do |format|
      format.html
      format.turbo_stream do
        @live_results = @results.is_a?(Array) ? @results.first(10) : @results.limit(10)
        render :live_search
      end
    end
  end
end
