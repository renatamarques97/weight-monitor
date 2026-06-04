require 'rails_helper'

RSpec.describe '/meal_diaries', type: :request do
  describe 'when user is not signed in' do
    describe 'GET /index' do
      it 'redirects to sign in' do
        get meal_diaries_url
        expect(response).to have_http_status(302)
      end
    end
  end

  describe 'when user is not allowed' do
    let(:user) { create(:user) }
    let(:user_not_allowed) { create(:user) }
    let(:meal_diary) { create(:meal_diary, user: user) }

    before do
      sign_in user_not_allowed
    end

    it 'returns code 401 on edit' do
      get edit_meal_diary_url(meal_diary)
      expect(response).to have_http_status(401)
    end
  end

  describe 'when user is signed in' do
    let!(:user) { create(:user) }

    before do
      sign_in user
    end

    let(:valid_attributes) do
      {
        diary_date: Date.current,
        notes: 'My daily log',
        meals_attributes: {
          '0' => {
            schedule: '08:00',
            description: 'Breakfast',
            meal_type: 'breakfast',
            meal_foods_attributes: {
              '0' => {
                food_name: 'Banana',
                metric_serving_amount: 100,
                metric_serving_unit: 'g',
                calories: 89,
                protein: 1.1,
                carbs: 22.8,
                fat: 0.3
              }
            }
          }
        }
      }
    end

    let(:invalid_attributes) do
      {
        diary_date: nil,
        notes: 'Invalid diary'
      }
    end

    describe 'GET /index' do
      it 'renders a successful response' do
        create(:meal_diary, user: user)
        get meal_diaries_url
        expect(response).to be_successful
      end
    end

    describe 'GET /show' do
      it 'renders a successful response' do
        meal_diary = create(:meal_diary, user: user)
        get meal_diary_url(meal_diary)
        expect(response).to be_successful
      end
    end

    describe 'GET /new' do
      it 'renders a successful response' do
        get new_meal_diary_url
        expect(response).to be_successful
      end
    end

    describe 'GET /edit' do
      it 'renders a successful response' do
        meal_diary = create(:meal_diary, user: user)
        get edit_meal_diary_url(meal_diary)
        expect(response).to be_successful
      end
    end

    describe 'POST /create' do
      context 'with valid parameters' do
        it 'creates a new MealDiary' do
          expect {
            post meal_diaries_url, params: { meal_diary: valid_attributes }
          }.to change(MealDiary, :count).by(1)
        end

        it 'creates nested meal and meal_food' do
          expect {
            post meal_diaries_url, params: { meal_diary: valid_attributes }
          }.to change(Meal, :count).by(1).and change(MealFood, :count).by(1)
        end

        it 'redirects to meal diaries index' do
          post meal_diaries_url, params: { meal_diary: valid_attributes }
          expect(response).to redirect_to(meal_diaries_path)
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new MealDiary' do
          expect {
            post meal_diaries_url, params: { meal_diary: invalid_attributes }
          }.to change(MealDiary, :count).by(0)
        end

        it 'renders a successful response' do
          post meal_diaries_url, params: { meal_diary: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    describe 'PATCH /update' do
      let(:new_attributes) { { notes: 'Updated notes', diary_date: Date.current } }

      it 'updates the requested meal diary' do
        meal_diary = create(:meal_diary, user: user)
        patch meal_diary_url(meal_diary), params: { meal_diary: new_attributes }
        meal_diary.reload
        expect(meal_diary.notes).to eq('Updated notes')
      end

      it 'redirects to meal diaries index' do
        meal_diary = create(:meal_diary, user: user)
        patch meal_diary_url(meal_diary), params: { meal_diary: new_attributes }
        expect(response).to redirect_to(meal_diaries_path)
      end
    end

    describe 'DELETE /destroy' do
      it 'destroys the requested meal diary' do
        meal_diary = create(:meal_diary, user: user)
        expect {
          delete meal_diary_url(meal_diary)
        }.to change(MealDiary, :count).by(-1)
      end

      it 'redirects to meal diaries list' do
        meal_diary = create(:meal_diary, user: user)
        delete meal_diary_url(meal_diary)
        expect(response).to redirect_to(meal_diaries_path)
      end
    end
  end
end
