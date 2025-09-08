class Forge::BaseController < ApplicationController
  include Paginatable
  include Pundit::Authorization

  before_action :require_authentication

  layout "forge"

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    # Возвращаем пользователя назад или на дашборд, если "назад" невозможно
    redirect_to(request.referer || forge_dashboard_path)
  end
end
