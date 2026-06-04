require 'rails_helper'

RSpec.describe MealDiary, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:meals).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:diary_date) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:meals) }
  end

  describe 'scope' do
    let(:user) { create(:user) }
    let(:meal_diary) { create(:meal_diary, user: user) }

    context 'when user has meal diaries' do
      it 'returns valid meal diary' do
        meal_diary
        expect(described_class.authorized_user(user)).to include(meal_diary)
      end
    end

    context 'when user does not have meal diaries' do
      it 'returns empty array' do
        expect(described_class.authorized_user(user)).to eq([])
      end
    end
  end
end
