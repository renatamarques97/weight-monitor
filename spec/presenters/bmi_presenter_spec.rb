# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BmiPresenter do
  describe '#call' do
    let(:user) { create(:user, height: 1.70) }
    let(:diet) { create(:diet, user_id: user.id) }
    let(:weight) { create(:weight, value: 80, user_id: user.id) }
    let(:bmi) { 27.68 }

    context 'when bmi is not valid' do
      let(:user) { create(:user, height: nil) }

      it 'weight and height is nil' do
        expect(described_class.new(user).call).to eq(0)
      end

      it 'weight is nil' do
        diet
        expect(described_class.new(user).call).to eq(0)
      end

      it 'height is nil' do
        weight
        expect(described_class.new(user).call).to eq(0)
      end
    end

    context 'when bmi is valid' do
      it 'weight and height exist' do
        diet
        weight
        expect(described_class.new(user).call).to eq(bmi)
      end

      it 'calculates correctly when weight is in lbs and height is in ft' do
        user_lbs_ft = create(:user, height: 5.58, height_unit: Units::HEIGHTS::FT)
        create(:weight, value: 176.37, weight_unit: Units::WEIGHTS::LBS, user: user_lbs_ft)
        expect(described_class.new(user_lbs_ft).call).to eq(27.68)
      end

      it 'uses the latest weight by date, not the last one created' do
        create(:weight, value: 80, weight_date: Date.current, user: user)
        create(:weight, value: 90, weight_date: 3.days.ago, user: user)
        expect(described_class.new(user).call).to eq(bmi)
      end

      it 'calculates correctly when height is in cm' do
        user_cm = create(:user, height: 170.0, height_unit: Units::HEIGHTS::CM)
        create(:weight, value: 80.0, weight_unit: Units::WEIGHTS::KG, user: user_cm)
        expect(described_class.new(user_cm).call).to eq(27.68)
      end
    end
  end
end
