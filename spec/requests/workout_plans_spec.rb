# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/workout_plans', type: :request do
  let(:client) { create(:user) }
  let(:educator) do
    create(:user, account_type: :professional, professional_type: :physical_educator,
                  country_code: 'BR', professional_credential: 'CREF',
                  professional_registration_number: '456')
  end

  before do
    create(:professional_assignment, client:, physical_educator: educator)
  end

  it 'allows a free or premium client to view their plan' do
    plan = create(:workout_plan, user: client, physical_educator: educator)
    sign_in client

    get workout_plan_path(plan)

    expect(response).to be_successful
  end

  it 'does not allow a client to edit a plan' do
    plan = create(:workout_plan, user: client, physical_educator: educator)
    sign_in client

    get edit_workout_plan_path(plan)

    expect(response).to have_http_status(:unauthorized)
  end

  it 'allows an assigned educator to create a plan' do
    sign_in educator

    expect do
      post workout_plans_path,
           params: { user_id: client.id,
                     workout_plan: { start_date: Date.current,
                                     end_date: 4.weeks.from_now.to_date } }
    end.to change(WorkoutPlan, :count).by(1)

    expect(response).to redirect_to(workout_plan_path(WorkoutPlan.last))
  end

  it 'does not allow an unassigned educator to create a plan' do
    unassigned = create(:user, account_type: :professional, professional_type: :physical_educator,
                               country_code: 'BR', professional_credential: 'CREF',
                               professional_registration_number: '789')
    sign_in unassigned

    get new_workout_plan_path, params: { user_id: client.id }

    expect(response).to redirect_to(workout_plans_path)
  end

  it 'allows an assigned educator to update a plan' do
    plan = create(:workout_plan, user: client, physical_educator: educator)
    sign_in educator

    patch workout_plan_path(plan), params: { workout_plan: { end_date: 8.weeks.from_now.to_date } }

    expect(response).to redirect_to(workout_plan_path(plan))
    expect(plan.reload.end_date).to eq(8.weeks.from_now.to_date)
  end

  it 'allows an admin to view all plans' do
    create(:workout_plan, user: client, physical_educator: educator)
    sign_in create(:user, account_type: :admin)

    get workout_plans_path

    expect(response).to be_successful
  end
end
