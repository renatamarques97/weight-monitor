# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkoutPlanPolicy do
  let(:client) { create(:user) }
  let(:educator) do
    create(:user, account_type: :professional, professional_type: :physical_educator,
                  country_code: 'BR', professional_credential: 'CREF',
                  professional_registration_number: '456')
  end
  let(:plan) { create(:workout_plan, user: client, physical_educator: educator) }

  before do
    create(:professional_assignment, client:, physical_educator: educator)
  end

  it 'allows the client to view but not manage' do
    policy = described_class.new(client, plan)

    expect(policy.view?).to be(true)
    expect(policy.manage?).to be(false)
  end

  it 'allows the assigned educator to view and manage' do
    policy = described_class.new(educator, plan)

    expect(policy.view?).to be(true)
    expect(policy.manage?).to be(true)
  end

  it 'allows admin to view' do
    policy = described_class.new(create(:user, account_type: :admin), plan)

    expect(policy.view?).to be(true)
  end

  it 'allows creation only for an assigned client' do
    policy = described_class.new(educator, plan)

    expect(policy.create?(client)).to be(true)
    expect(policy.create?(create(:user))).to be(false)
  end
end
