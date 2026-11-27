# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkoutPlanSession, type: :model do
  it 'requires the session date to be within the plan period' do
    plan = create(:workout_plan, start_date: Date.current, end_date: 1.week.from_now.to_date)
    session = build(:workout_plan_session, workout_plan: plan, session_date: 1.week.from_now.to_date + 1.day)

    expect(session).not_to be_valid
  end

  it 'rejects a duplicate session date in the same plan' do
    plan = create(:workout_plan)
    create(:workout_plan_session, workout_plan: plan, session_date: Date.current)

    duplicate = build(:workout_plan_session, workout_plan: plan, session_date: Date.current)

    expect(duplicate).not_to be_valid
  end

  it 'accepts valid session details and workout type' do
    session = build(:workout_plan_session)

    expect(session).to be_valid
  end
end
