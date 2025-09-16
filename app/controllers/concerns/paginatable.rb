module Paginatable
  extend ActiveSupport::Concern

  included do
    helper_method :per_page
  end

  def per_page
    raw_limit = params[:limit] || params[:items]
    val = raw_limit.to_i if raw_limit.present?
    (val && val > 0 ? val : Pagy::DEFAULT[:limit]).clamp(5, Pagy::DEFAULT[:max_limit] || 200)
  end
end
