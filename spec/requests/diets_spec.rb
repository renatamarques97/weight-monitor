require 'rails_helper'

RSpec.describe "/diets", type: :request do
  describe "when user is not signed in" do
    describe "GET /index" do
      it "redirects to the index" do
        get diets_url
        expect(response).to have_http_status(302)
      end
    end
  end

  describe "When User is signed in" do
    let!(:user) { create(:user) }

    before do
      sign_in user
    end

    let(:valid_attributes) { attributes_for(:diet, user_id: user.id) }

    let(:invalid_attributes) do
      attributes_for(:diet, target_weight: nil, user_id: user.id)
    end

    describe "GET /index" do
      it "renders a successful response" do
        Diet.create! valid_attributes
        get diets_url
        expect(response).to be_successful
      end
    end

    describe "GET /show" do
      it "renders a successful response" do
        diet = Diet.create! valid_attributes
        get diet_url(diet)
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_diet_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it "render a successful response" do
        diet = Diet.create! valid_attributes
        get edit_diet_url(diet)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new Diet" do
          expect {
            post diets_url, params: { diet: valid_attributes }
          }.to change(Diet, :count).by(1)
        end

        it "redirects to the created diet" do
          post diets_url, params: { diet: valid_attributes }
          expect(response).to redirect_to(root_path)
        end
      end

      context "with invalid parameters" do
        it "does not create a new Diet" do
          expect {
            post diets_url, params: { diet: invalid_attributes }
          }.to change(Diet, :count).by(0)
        end

        it "renders a successful response (i.e. to display the 'new' template)" do
          post diets_url, params: { diet: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_attributes) { attributes_for(:diet, user_id: user.id) }

        it "updates the requested diet" do
          diet = Diet.create! valid_attributes
          patch diet_url(diet), params: { diet: new_attributes }
          diet.reload
          expect(response).to have_http_status(302)
        end

        it "redirects to the diet" do
          diet = Diet.create! valid_attributes
          patch diet_url(diet), params: { diet: new_attributes }
          diet.reload
          expect(response).to redirect_to(root_path)
        end
      end

      context "with invalid parameters" do
        it "renders a successful response (i.e. to display the 'edit' template)" do
          diet = Diet.create! valid_attributes
          patch diet_url(diet), params: { diet: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested diet" do
        diet = Diet.create! valid_attributes
        expect {
          delete diet_url(diet)
        }.to change(Diet, :count).by(-1)
      end

      it "redirects to the diets list" do
        diet = Diet.create! valid_attributes
        delete diet_url(diet)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
