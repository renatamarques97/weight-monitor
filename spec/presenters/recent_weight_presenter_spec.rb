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
end
