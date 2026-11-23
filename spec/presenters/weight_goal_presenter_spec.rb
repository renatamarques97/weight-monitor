# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeightGoalPresenter do
  describe '#achieved' do
    let(:user) { create(:user) }
    let(:valid_diet) { create(:diet, target_weight: 80, user: user) }
    let(:valid_weight) { create(:weight, kg: 80, user: user) }

    let(:diet) { create(:diet, target_weight: 80, user: user) }
    let(:weight) { create(:weight, kg: 90, user: user) }

    context 'when goal was not achieved' do
      it "weight and target weight don't match" do
        diet
        weight
        expect(described_class.new(user).achieved?).to be(false)
      end

      it 'weight is nil' do
        diet
        expect(described_class.new(user).achieved?).to be(false)
      end

      it 'target weight is nil' do
        weight
        expect(described_class.new(user).achieved?).to be(false)
      end
    end

    context 'when goal was achieved' do
      it 'weight and target weight match' do
        valid_diet
        valid_weight
        expect(described_class.new(user).achieved?).to be(true)
      end
    end
  end

  describe '#progress_percent' do
    let(:user) { create(:user) }

    it 'returns 50 percent halfway from initial to target weight' do
      create(:diet, user: user, initial_weight: 100, target_weight: 80)
      create(:weight, user: user, kg: 90)

      expect(described_class.new(user).progress_percent).to eq(50)
    end

    it 'clamps progress at zero and 100 percent' do
      create(:diet, user: user, initial_weight: 100, target_weight: 80)
      create(:weight, user: user, kg: 110)

      presenter = described_class.new(user)
      expect(presenter.progress_percent).to eq(0)

      create(:weight, user: user, kg: 75)
      expect(presenter.progress_percent).to eq(100)
    end

    it 'works when the goal is weight gain' do
      create(:diet, user: user, initial_weight: 70, target_weight: 80)
      create(:weight, user: user, kg: 75)

      expect(described_class.new(user).progress_percent).to eq(50)
    end
  end
end
