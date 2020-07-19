require 'rails_helper'

RSpec.describe "/diets", type: :request do
  describe "when user is not signed in" do
    describe "GET /index" do
      it "redirects to the index" do
        get root_path
        expect(response).to have_http_status(302)
      end
    end
  end

  describe "When User is signed in" do
    let!(:user) { create(:user) }

    before do
      sign_in user
    end

    describe "GET /index" do
      it "renders a successful response" do
        get root_path
        expect(response).to be_successful
      end
    end
  end
end
