# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/dashboard', type: :request do
  describe 'when user is not signed in' do
    describe 'GET /index' do
      it 'redirects to the index' do
        get root_path
        expect(response).to have_http_status(302)
      end
    end
  end

  describe 'when user is signed in' do
    let!(:user) { create(:user) }

    before do
      sign_in user
      create(:weight, user: user, value: 70.5, weight_date: 2.days.ago)
      create(:weight, user: user, value: 72.3, weight_date: 1.day.ago)
    end

    describe 'GET /index' do
      it 'renders a successful response' do
        get root_path
        expect(response).to be_successful
      end

      it 'uses default period when period is not provided' do
        expect(WeightQuery).to receive(:weights).with(user, 30).and_call_original
        expect(WorkoutQuery).to receive(:chart_data).with(user, 30).and_call_original

        get root_path
      end

      it 'uses period from params when provided' do
        expect(WeightQuery).to receive(:weights).with(user, 60).and_call_original
        expect(WorkoutQuery).to receive(:chart_data).with(user, 60).and_call_original

        get root_path, params: { period_in_days: 60, active_tab: 'running' }
      end

      it 'renders all day-period controls and preserves the tab scroll position' do
        get root_path, params: { period_in_days: 90, active_tab: 'cycling' }

        expect(response).to be_successful
        expect(response.body).to include('30')
        expect(response.body).to include('60')
        expect(response.body).to include('90')
        expect(response.body).to include('tabs#savePeriodScroll')
        expect(response.body).to include('data-scroll-position-key-value="dashboard-tabs-scroll"')
      end

      it 'keeps the requested active workout tab' do
        get root_path, params: { period_in_days: 60, active_tab: 'soccer' }

        expect(response).to be_successful
        expect(response.body).to include('data-tabs-active-tab-value="soccer"')
      end

      it 'shows meal diary streak and total weeks with records' do
        create(:meal_diary, user: user, diary_date: Date.current)
        create(:meal_diary, user: user, diary_date: 1.week.ago.to_date)

        get root_path

        expect(response).to be_successful
        expect(response.body).to include(I18n.t('dashboard.streak_weeks', count: 2))
        expect(response.body).to include(I18n.t('dashboard.total_weeks', count: 2))
      end

      it 'shows total workout duration for the current month' do
        create(:running, user: user, workout_date: Time.current.to_date, duration: 75)
        create(:cycling, user: user, workout_date: Time.current.to_date, duration: 20)
        create(:running, user: user, workout_date: 1.month.ago.to_date, duration: 60)

        get root_path

        expect(response).to be_successful
        expect(response.body).to include(I18n.t('workout.training'))
        expect(response.body).to include(I18n.t('workout.training_duration', hours: 1, minutes: 35))
        expect(response.body).to include(I18n.t('workout.this_month'))
      end
    end
  end

  describe 'when user prefers lbs and mi' do
    let(:user) { create(:user, weight_unit: Units::WEIGHTS::LBS, distance_unit: Units::DISTANCES::MI) }

    before do
      sign_in user
      create(:weight, user: user, value: 70, weight_unit: Units::WEIGHTS::KG, weight_date: 1.day.ago)
    end

    it 'labels and converts the weight chart in the preferred unit' do
      get root_path

      expect(response.body).to include(I18n.t('weight.chart_label', unit: Units::WEIGHTS::LBS))
      expect(response.body).to include('154.32')
    end

    it 'shows the 30-day trend in the preferred unit' do
      create(:weight, user: user, value: 69, weight_unit: Units::WEIGHTS::KG, weight_date: Date.current)

      get root_path

      expect(response.body).to include(I18n.t('dashboard.weight_decreased', weight: 2.2, unit: Units::WEIGHTS::LBS))
    end
  end
end
