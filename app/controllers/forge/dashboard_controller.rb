# frozen_string_literal: true

class Forge::DashboardController < Forge::BaseController
  def index
    @default_lang = Language.find_by(code: Language::DEFAULT_CODE) || Language.order(:name).first
  end
end
