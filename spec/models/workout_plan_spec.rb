# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkoutPlan, type: :model do
  it 'requires an end date on or after the start date' do
    educator = create(:user, account_type: :professional, professional_type: :physical_educator,
                             country_code: 'BR', professional_credential: 'CREF',
                             professional_registration_number: '456')
    plan = described_class.new(user: create(:user), physical_educator: educator,
                               start_date: Date.current, end_date: Date.current - 1.day)

    expect(plan).not_to be_valid
  end

  it 'returns the latest plan as the current plan for a user' do
    user = create(:user)
    educator = create(:user, account_type: :professional, professional_type: :physical_educator,
                             country_code: 'BR', professional_credential: 'CREF',
                             professional_registration_number: '456')
    create(:workout_plan, user:, physical_educator: educator,
                          start_date: 2.weeks.ago.to_date, end_date: 1.week.ago.to_date)
    latest = create(:workout_plan, user:, physical_educator: educator,
                                   start_date: Date.current, end_date: 4.weeks.from_now.to_date)

    expect(user.current_workout_plan).to eq(latest)
  end
end
