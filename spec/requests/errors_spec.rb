require 'rails_helper'

RSpec.describe "Error Handling", type: :request do
  describe "GET /non-existent-page" do
    it "returns 404 not found status" do
      get "/non-existent-page"
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page Not Found")
      expect(response.body).to include("404")
    end
  end

  describe "GET /meal_diaries/:id/edit when record does not exist" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it "rescues ActiveRecord::RecordNotFound and returns 404 status" do
      get edit_meal_diary_path(id: 999_999)
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page Not Found")
      expect(response.body).to include("404")
    end
  end
end
