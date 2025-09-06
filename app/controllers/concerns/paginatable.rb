module Paginatable
  extend ActiveSupport::Concern

  included do
    helper_method :per_page
  end

  # Этот метод должен быть публичным
  def per_page
    # В документации, которую ты прислал, используется :limit, а не :per_page.
    # Давай приведём всё к единому стандарту Pagy.
    raw_limit = params[:limit] || params[:items] # Pagy использует :limit или :items
    val = raw_limit.to_i if raw_limit.present?
    # Pagy::DEFAULT[:limit] берётся из инициализатора, если в URL ничего нет.
    (val && val > 0 ? val : Pagy::DEFAULT[:limit]).clamp(5, Pagy::DEFAULT[:max_limit] || 200)
  end
end
