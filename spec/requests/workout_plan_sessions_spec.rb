# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/workout_plans/:workout_plan_id/sessions', type: :request do
  let(:client) { create(:user) }
  let(:educator) do
    create(:user, account_type: :professional, professional_type: :physical_educator,
                  country_code: 'BR', professional_credential: 'CREF',
                  professional_registration_number: '456')
  end
  let(:plan) { create(:workout_plan, user: client, physical_educator: educator) }
  let(:session) { create(:workout_plan_session, workout_plan: plan, session_date: plan.start_date) }

  before do
    create(:professional_assignment, client:, physical_educator: educator)
  end

  it 'allows the client to view a session' do
    sign_in client

    get workout_plan_session_path(plan, session)

    expect(response).to be_successful
  end

  it 'allows the assigned educator to view a session' do
    sign_in educator

    get workout_plan_session_path(plan, session)

    expect(response).to be_successful
  end

  it 'blocks an unrelated user' do
    sign_in create(:user)

    get workout_plan_session_path(plan, session)

    expect(response).to have_http_status(:unauthorized)
  end

  it 'allows an admin to view a session' do
    sign_in create(:user, account_type: :admin)

    get workout_plan_session_path(plan, session)

    expect(response).to be_successful
  end

  it 'shows the completed status when a workout is linked' do
    sign_in client
    create(:running, user: client, workout_plan_session: session, workout_date: session.session_date)

    get workout_plan_session_path(plan, session)

    expect(response).to be_successful
  end
end
