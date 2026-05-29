require 'rails_helper'

RSpec.describe "/workouts", type: :request do
  describe "when user is not signed in" do
    it "redirects index to sign in" do
      get workouts_path

      expect(response).to have_http_status(302)
    end
  end

  describe "when user is signed in" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    describe "GET /index" do
      it "renders a successful response" do
        create(:running, user: user)

        get workouts_path

        expect(response).to be_successful
      end

      it "filters workouts by type" do
        running = create(:running, user: user, workout_date: Date.new(2026, 5, 2))
        cycling = create(:cycling, user: user, workout_date: Date.new(2026, 5, 1))

        get workouts_path, params: { type: :running }

        expect(response).to be_successful
        expect(response.body).to include(running.workout_date.strftime("%b %d, %Y"))
        expect(response.body).not_to include(cycling.workout_date.strftime("%b %d, %Y"))
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_workout_path

        expect(response).to be_successful
      end

      it "initializes workout with default type (other)" do
        get new_workout_path

        expect(response).to be_successful
      end

      it "initializes workout with specified type from params" do
        get new_workout_path, params: { workout_type: :running }

        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      let(:workout) { create(:running, user: user) }

      it "renders a successful response" do
        get edit_workout_path(workout)

        expect(response).to be_successful
      end

      it "shows correct workout for editing" do
        get edit_workout_path(workout)

        expect(response.body).to include(workout.workout_date.to_s)
      end
    end

    describe "POST /create" do
      let(:valid_attributes) do
        {
          workout_type: :running,
          workout_date: Date.current,
          duration: 30,
          distance: 5.2,
          calories: 350,
          details: {}
        }
      end

      let(:invalid_attributes) do
        {
          workout_type: :running,
          workout_date: Date.current,
          duration: nil,
          distance: 5.2,
          details: {}
        }
      end

      it "creates a new workout" do
        expect do
          post workouts_path, params: { workout: valid_attributes }
        end.to change(Workout, :count).by(1)
      end

      it "redirects to root path after create" do
        post workouts_path, params: { workout: valid_attributes }

        expect(response).to redirect_to(root_path)
      end

      it "sets flash notice after successful create" do
        post workouts_path, params: { workout: valid_attributes }

        expect(flash[:notice]).to eq(I18n.t('workout.created'))
      end

      it "renders unprocessable entity with invalid parameters" do
        post workouts_path, params: { workout: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not set flash notice when creation fails" do
        post workouts_path, params: { workout: invalid_attributes }

        expect(flash[:notice]).to be_nil
      end
    end

    describe "PATCH /update" do
      let(:workout) { create(:running, user: user) }

      it "updates the requested workout" do
        patch workout_path(workout), params: { workout: { duration: 55 } }

        expect(response).to redirect_to(workouts_path)
        expect(workout.reload.duration).to eq(55.0)
      end

      it "sets flash notice on successful update" do
        patch workout_path(workout), params: { workout: { duration: 55 } }

        expect(flash[:notice]).to eq(I18n.t('workout.updated'))
      end

      it "renders edit with error status when update fails" do
        patch workout_path(workout), params: { workout: { duration: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(I18n.t('error.saved'))
      end

      it "returns not found when updating another user's workout" do
        another_user = create(:user)
        another_workout = create(:running, user: another_user)

        patch workout_path(another_workout), params: { workout: { duration: 55 } }

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "DELETE /destroy" do
      let!(:workout) { create(:running, user: user) }

      it "destroys the requested workout" do
        expect do
          delete workout_path(workout)
        end.to change(Workout, :count).by(-1)
      end

      it "redirects to workouts list" do
        delete workout_path(workout)

        expect(response).to redirect_to(workouts_path)
      end

      it "sets flash notice after successful destroy" do
        delete workout_path(workout)

        expect(flash[:notice]).to eq(I18n.t('workout.destroyed'))
      end

      it "returns not found when deleting another user's workout" do
        another_user = create(:user)
        another_workout = create(:running, user: another_user)

        expect do
          delete workout_path(another_workout)
        end.not_to change(Workout, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "when trying to access another user's workout" do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let(:another_users_workout) { create(:running, user: another_user) }

    before do
      sign_in user
    end

    it "returns not found for edit" do
      get edit_workout_path(another_users_workout)

      expect(response).to have_http_status(:not_found)
    end
  end
end
