require 'rails_helper'

RSpec.describe "Forge::Words", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/forge/words/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/forge/words/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/forge/words/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/forge/words/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/forge/words/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
