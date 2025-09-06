require 'rails_helper'

RSpec.describe "Forge::Lexemes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/forge/lexemes/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/forge/lexemes/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/forge/lexemes/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/forge/lexemes/create"
      expect(response).to have_http_status(:success)
    end
  end

end
