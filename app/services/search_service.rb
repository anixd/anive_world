class SearchService
  # scope - это начальный ActiveRecord::Relation (например, ContentEntry.all)
  # query_string - это строка из поискового поля
  def initialize(scope: ContentEntry.all, query_string: nil)
    @scope = scope
    @query_string = query_string.to_s.strip
  end

  def call
    # Если строка запроса не пустая, применяем наш pg_search_scope
    if @query_string.present?
      @scope = @scope.search_by_text(@query_string)
    end

    # В будущем здесь будет парсинг префиксов (ty:, an:, #)
    # и применение дополнительных фильтров .where(...) и .joins(...)

    @scope
  end
end
