require 'rails_helper'

RSpec.describe "Forge::Dashboards", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/forge/dashboard/index"
      expect(response).to have_http_status(:success)
    end
  end

end
