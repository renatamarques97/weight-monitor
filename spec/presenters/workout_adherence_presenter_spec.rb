# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkoutAdherencePresenter do
  it 'returns not_set without a workout plan' do
    presenter = described_class.new(create(:user))

    expect(presenter.state).to eq(:not_set)
    expect(presenter.adherence_percent).to be_nil
  end

  it 'returns no_plan for a plan without sessions' do
    user = create(:user)
    create(:workout_plan, user: user)

    presenter = described_class.new(user)

    expect(presenter.state).to eq(:no_plan)
    expect(presenter.adherence_percent).to be_nil
  end

  it 'calculates adherence from completed sessions' do
    user = create(:user)
    plan = create(:workout_plan, user: user)
    completed = create(:workout_plan_session, workout_plan: plan, session_date: plan.start_date)
    create(:running, user: user, workout_plan_session: completed, workout_date: completed.session_date)
    create(:workout_plan_session, workout_plan: plan, session_date: plan.start_date + 1.day,
                                  workout_type: :cycling)

    presenter = described_class.new(user)

    expect(presenter.state).to eq(:tracked)
    expect(presenter.adherence_percent).to eq(50)
  end

  it 'returns 100 percent when every session is completed' do
    user = create(:user)
    plan = create(:workout_plan, user: user)
    session = create(:workout_plan_session, workout_plan: plan, session_date: plan.start_date)
    create(:running, user: user, workout_plan_session: session, workout_date: session.session_date)

    presenter = described_class.new(user)

    expect(presenter.adherence_percent).to eq(100)
  end

  it 'returns 0 percent when no session is completed' do
    user = create(:user)
    plan = create(:workout_plan, user: user)
    create(:workout_plan_session, workout_plan: plan, session_date: plan.start_date)

    presenter = described_class.new(user)

    expect(presenter.adherence_percent).to eq(0)
  end
end
