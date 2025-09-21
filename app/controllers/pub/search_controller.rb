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
                   Lexeme.published
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
      format.html # Обычный ответ для полной перезагрузки страницы
      format.turbo_stream do # Ответ для "живого" поиска
        # Для выпадающего списка берем только первые 10
        @live_results = @results.is_a?(Array) ? @results.first(10) : @results.limit(10)
        render :live_search
      end
    end
  end
end
