class Forge::DashboardController < Forge::BaseController
  def index
    @first_lang = Language.find_by(code: Language::DEFAULT_CODE) || Language.order(:name).first
  end
end
