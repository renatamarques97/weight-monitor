# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecentWeightPresenter do
  describe '#call' do
    let(:user) { create(:user) }

    context 'when user has no weights' do
      it 'returns nil' do
        expect(described_class.new(user).call).to be_nil
      end
    end

    context 'when user has weights' do
      it 'returns the most recent weight by weight_date' do
        create(:weight, user: user, kg: 79.5, weight_date: Date.current - 3.days)
        create(:weight, user: user, kg: 78.2, weight_date: Date.current)

        expect(described_class.new(user).call).to eq(78.2)
      end
    end
  end

  describe '#trend_30_days' do
    let(:user) { create(:user) }

    it 'returns the weight decrease over the last 30 days' do
      create(:weight, user: user, kg: 90, weight_date: 20.days.ago)
      create(:weight, user: user, kg: 85, weight_date: Date.current)

      expect(described_class.new(user).trend_30_days).to eq(-5.0)
    end

    it 'returns the weight increase over the last 30 days' do
      create(:weight, user: user, kg: 70, weight_date: 25.days.ago)
      create(:weight, user: user, kg: 72.5, weight_date: Date.current)

      expect(described_class.new(user).trend_30_days).to eq(2.5)
    end

    it 'returns nil with fewer than two records' do
      create(:weight, user: user, kg: 80)

      expect(described_class.new(user).trend_30_days).to be_nil
    end

    it 'ignores records older than 30 days' do
      create(:weight, user: user, kg: 95, weight_date: 31.days.ago)
      create(:weight, user: user, kg: 90, weight_date: 20.days.ago)
      create(:weight, user: user, kg: 85, weight_date: Date.current)

      expect(described_class.new(user).trend_30_days).to eq(-5.0)
    end
  end
end
