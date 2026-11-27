# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/diets', type: :request do
  describe 'when user is not signed in' do
    describe 'GET /index' do
      it 'redirects to the index' do
        get diets_url
        expect(response).to have_http_status(302)
      end
    end
  end

  describe 'when user is not allowed' do
    let(:user) { create(:user) }
    let(:user_not_allowed) { create(:user) }
    let(:valid_attributes) { attributes_for(:diet, user_id: user.id) }

    before do
      sign_in user_not_allowed
    end

    describe 'GET /index' do
      it 'return code 401' do
        diet = Diet.create! valid_attributes
        get edit_diet_url(diet)
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'When User is signed in' do
    let!(:user) { create(:user, account_type: :admin) }
    let(:valid_attributes) { attributes_for(:diet, user_id: user.id) }
    let(:invalid_attributes) do
      attributes_for(:diet, target_weight: nil, user_id: user.id)
    end

    before do
      sign_in user
    end

    describe 'GET /index' do
      it 'renders a successful response' do
        Diet.create! valid_attributes
        get diets_url
        expect(response).to be_successful
      end
    end

    describe 'GET /show' do
      it 'renders a successful response' do
        diet = Diet.create! valid_attributes
        get diet_url(diet)
        expect(response).to be_successful
      end

      it 'shows meal schedules, foods, servings and macros' do
        diet = Diet.create! valid_attributes
        meal = diet.meals.create!(schedule: '07:30', description: 'Morning meal', meal_type: :breakfast)
        meal.meal_foods.create!(
          food_name: 'Oats', metric_serving_amount: 80, metric_serving_unit: 'g',
          calories: 300, protein: 10, carbs: 54, fat: 6
        )

        get diet_url(diet)

        expect(response.body).to include('07:30', 'Morning meal', 'Oats', '80', 'g', '300', '10', '54', '6')
      end
    end

    describe 'GET /new' do
      it 'renders a successful response' do
        get new_diet_url
        expect(response).to be_successful
      end
    end

    describe 'GET /edit' do
      it 'render a successful response' do
        diet = Diet.create! valid_attributes
        get edit_diet_url(diet)
        expect(response).to be_successful
      end
    end

    describe 'POST /create' do
      context 'with valid parameters' do
        it 'creates a new Diet' do
          expect do
            post diets_url, params: { diet: valid_attributes }
          end.to change(Diet, :count).by(1)
        end

        it 'redirects to the created diet' do
          post diets_url, params: { diet: valid_attributes }
          expect(response).to redirect_to(root_path)
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new Diet' do
          expect do
            post diets_url, params: { diet: invalid_attributes }
          end.not_to change(Diet, :count)
        end

        it "renders a successful response (i.e. to display the 'new' template)" do
          post diets_url, params: { diet: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    describe 'PATCH /update' do
      context 'with valid parameters' do
        let(:new_attributes) { attributes_for(:diet, user_id: user.id) }

        it 'updates the requested diet' do
          diet = Diet.create! valid_attributes
          patch diet_url(diet), params: { diet: new_attributes }
          diet.reload
          expect(response).to have_http_status(302)
        end

        it 'redirects to the diet' do
          diet = Diet.create! valid_attributes
          patch diet_url(diet), params: { diet: new_attributes }
          diet.reload
          expect(response).to redirect_to(root_path)
        end

        it 'does not move the diet to another user' do
          diet = Diet.create! valid_attributes
          other_user = create(:user)

          patch diet_url(diet), params: { diet: { target_weight: 70, user_id: other_user.id } }

          expect(response).to redirect_to(root_path)
          expect(diet.reload).to have_attributes(user_id: user.id, target_weight: 70)
        end

        it 'keeps the weight unit chosen for the diet' do
          diet = Diet.create! valid_attributes
          patch diet_url(diet), params: { diet: { target_weight: 150, weight_unit: MeasurementUnits::WEIGHTS::LBS } }

          expect(diet.reload).to have_attributes(target_weight: 150, weight_unit: MeasurementUnits::WEIGHTS::LBS)
        end
      end

      context 'with invalid parameters' do
        it "renders a successful response (i.e. to display the 'edit' template)" do
          diet = Diet.create! valid_attributes
          patch diet_url(diet), params: { diet: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    describe 'DELETE /destroy' do
      it 'destroys the requested diet' do
        diet = Diet.create! valid_attributes
        expect do
          delete diet_url(diet)
        end.to change(Diet, :count).by(-1)
      end

      it 'redirects to the diets list' do
        diet = Diet.create! valid_attributes
        delete diet_url(diet)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
