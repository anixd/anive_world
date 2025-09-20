class Pub::SearchController < Pub::BaseController
  def index
    @query = params[:q].to_s.strip
    @scope_name = params.fetch(:scope, "lore")

    return @results = [] if @query.blank?

    # Определяем, в каких моделях искать, в зависимости от выбранной вкладки
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

    # pagy_array нужен для результатов из словаря, которые возвращаются как массив
    @pagy, @results = results.is_a?(Array) ? pagy_array(results) : pagy(results)
  end
end
