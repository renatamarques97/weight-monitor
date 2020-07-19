require 'rails_helper'

RSpec.describe "Weights", type: :request do
  describe "GET /new" do
    it "renders a successful response" do
      get "/weights/new"
      expect(response).to be_successful
    end
  end

  let(:user) { create(:user) }
  let(:weight) { create(:weight, user_id: user.id) }
  let(:valid_attributes) { attributes_for(:weight, user_id: user.id) }
  let(:invalid_attributes) { attributes_for(:weight, kg: nil, user_id: user.id) }

  before do
    sign_in user
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Weight" do
        expect {
          post weights_url, params: { weight: valid_attributes }
        }.to change(Weight, :count).by(1)
      end

      it "redirects to the created weight" do
        post weights_url, params: { weight: valid_attributes }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Weight" do
        expect {
          post weights_url, params: { weight: invalid_attributes }
        }.to change(Weight, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post weights_url, params: { weight: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end
end
