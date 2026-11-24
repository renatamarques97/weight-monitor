# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diet, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:initial_weight) }
    it { is_expected.to validate_presence_of(:target_weight) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_numericality_of(:initial_weight).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:target_weight).is_greater_than(0) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:meals) }
  end

  describe 'scope' do
    let(:user) { create(:user) }
    let(:diet) { create(:diet, user_id: user.id) }

    context 'when user has diets' do
      it 'returns valid diet' do
        diet
        expect(described_class.authorized_user(user)).to include(diet)
      end
    end

    context 'when user does not have diets' do
      it 'returns empty array' do
        expect(described_class.authorized_user(user)).to eq([])
      end
    end
  end

  describe 'weight formatting' do
    let(:user) { create(:user) }

    it 'rounds initial and target weight to one decimal place' do
      diet = build(:diet, user: user, initial_weight: 77.87161889553765,
                          target_weight: 70.246789)

      diet.valid?

      expect(diet.initial_weight).to eq(77.9)
      expect(diet.target_weight).to eq(70.2)
    end
  end
end
