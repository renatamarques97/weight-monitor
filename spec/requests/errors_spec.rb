require 'rails_helper'

RSpec.describe "Error Handling", type: :request do
  shared_examples "a not found response" do
    it "returns the custom 404 page" do
      subject

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include(I18n.t('errors.not_found.title'))
      expect(response.body).to include(I18n.t('errors.not_found.description'))
      expect(response.body).to include(I18n.t('errors.not_found.home_button'))
    end
  end

  describe "GET /non-existent-page" do
    subject { get "/non-existent-page" }

    it_behaves_like "a not found response"
  end

  describe "GET /meal_diaries/:id/edit when record does not exist" do
    let(:user) { create(:user) }

    before { sign_in user }

    subject { get edit_meal_diary_path(id: 999_999) }

    it_behaves_like "a not found response"
  end
end
