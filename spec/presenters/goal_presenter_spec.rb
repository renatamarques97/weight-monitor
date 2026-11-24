# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoalPresenter do
  describe '#achieved?' do
    subject(:achieved) { described_class.new(user).achieved? }

    let(:user) { create(:user) }

    def diet(initial:, target:, unit: WEIGHTS::KG)
      create(:diet, user: user, initial_weight: initial, target_weight: target, weight_unit: unit)
    end

    def weight(value, unit: WEIGHTS::KG, date: Date.current)
      create(:weight, user: user, value: value, weight_unit: unit, weight_date: date)
    end

    it 'is false without a diet' do
      weight(70)
      expect(achieved).to be(false)
    end

    it 'is false without a weight' do
      diet(initial: 90, target: 80)
      expect(achieved).to be(false)
    end

    context 'when the diet is for losing weight' do
      before { diet(initial: 90, target: 80) }

      it 'is achieved at the target' do
        weight(80)
        expect(achieved).to be(true)
      end

      it 'is achieved below the target' do
        weight(78.4)
        expect(achieved).to be(true)
      end

      it 'is not achieved above the target' do
        weight(80.1)
        expect(achieved).to be(false)
      end
    end

    context 'when the diet is for gaining weight' do
      before { diet(initial: 70, target: 75) }

      it 'is achieved above the target' do
        weight(75.6)
        expect(achieved).to be(true)
      end

      it 'is not achieved below the target' do
        weight(74.9)
        expect(achieved).to be(false)
      end
    end

    context 'when the diet is for keeping the weight' do
      before { diet(initial: 70, target: 70) }

      it 'is achieved within the tolerance' do
        weight(70.4)
        expect(achieved).to be(true)
      end

      it 'is not achieved outside the tolerance' do
        weight(70.6)
        expect(achieved).to be(false)
      end
    end

    it 'compares weights recorded in another unit' do
      diet(initial: 90, target: 70)
      weight(154.3, unit: WEIGHTS::LBS)

      expect(achieved).to be(true)
    end

    it 'uses the latest weight by date, not the last one created' do
      diet(initial: 90, target: 80)
      weight(79, date: Date.current)
      weight(85, date: 3.days.ago)

      expect(achieved).to be(true)
    end

    it 'uses the diet that ends last' do
      create(:diet, user: user, initial_weight: 90, target_weight: 80, end_date: 1.month.from_now)
      create(:diet, user: user, initial_weight: 90, target_weight: 60, end_date: 1.month.ago,
                    start_date: 2.months.ago)
      weight(79)

      expect(achieved).to be(true)
    end
  end
end
