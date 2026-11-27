# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/meals', type: :request do
  let(:user) { create(:user) }
  let(:diet) { create(:diet, user_id: user.id) }
  let(:valid_attributes) { attributes_for(:meal, diet_id: diet.id) }
  let(:invalid_attributes) { attributes_for(:meal, meal_type: nil, diet_id: diet.id) }

  describe 'GET /index' do
    it 'renders a successful response' do
      Meal.create! valid_attributes
      get meals_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      meal = Meal.create! valid_attributes
      get meal_url(meal)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_meal_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'render a successful response' do
      meal = Meal.create! valid_attributes
      get edit_meal_url(meal)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Meal' do
        expect do
          post meals_url, params: { meal: valid_attributes }
        end.to change(Meal, :count).by(1)
      end

      it 'redirects to the created meal' do
        post meals_url, params: { meal: valid_attributes }
        expect(response).to redirect_to(meal_url(Meal.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Meal' do
        expect do
          post meals_url, params: { meal: invalid_attributes }
        end.not_to change(Meal, :count)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post meals_url, params: { meal: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { attributes_for(:meal, diet_id: diet.id) }

      it 'updates the requested meal' do
        meal = Meal.create! valid_attributes
        patch meal_url(meal), params: { meal: new_attributes }
        meal.reload
        expect(response).to have_http_status(302)
      end

      it 'redirects to the meal' do
        meal = Meal.create! valid_attributes
        patch meal_url(meal), params: { meal: new_attributes }
        meal.reload
        expect(response).to redirect_to(meal_url(meal))
      end
    end

    context 'with invalid parameters' do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        meal = Meal.create! valid_attributes
        patch meal_url(meal), params: { meal: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested meal' do
      meal = Meal.create! valid_attributes
      expect do
        delete meal_url(meal)
      end.to change(Meal, :count).by(-1)
    end

    it 'redirects to the meals list' do
      meal = Meal.create! valid_attributes
      delete meal_url(meal)
      expect(response).to redirect_to(meals_url)
    end
  end

  describe 'JSON responses' do
    it 'creates a meal with JSON' do
      post meals_url, params: { meal: valid_attributes }, as: :json
      expect(response).to have_http_status(:created)
    end

    it 'returns errors for invalid JSON creation' do
      post meals_url, params: { meal: invalid_attributes }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'updates a meal with JSON' do
      meal = Meal.create! valid_attributes
      patch meal_url(meal), params: { meal: valid_attributes }, as: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
