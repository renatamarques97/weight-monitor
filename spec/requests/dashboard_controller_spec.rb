require 'rails_helper'

RSpec.describe "/dashboard", type: :request do
  describe "when user is not signed in" do
    describe "GET /index" do
      it "redirects to the index" do
        get root_path
        expect(response).to have_http_status(302)
      end
    end
  end

  describe "when user is signed in" do
    let!(:user) { create(:user) }

    before do
      sign_in user
      create(:weight, user: user, kg: 70.5, weight_date: 2.days.ago)
      create(:weight, user: user, kg: 72.3, weight_date: 1.day.ago)
    end

    describe "GET /index" do
      it "renders a successful response" do
        get root_path
        expect(response).to be_successful
      end

      it "uses default period when period is not provided" do
        expect(WeightQuery).to receive(:weights).with(user, 30).and_call_original
        expect(WorkoutQuery).to receive(:chart_data).with(user, 30).and_call_original

        get root_path
      end

      it "uses period from params when provided" do
        expect(WeightQuery).to receive(:weights).with(user, 60).and_call_original
        expect(WorkoutQuery).to receive(:chart_data).with(user, 60).and_call_original

        get root_path, params: { period_in_days: 60, active_tab: 'running' }
      end
    end
  end
end
