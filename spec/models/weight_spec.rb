require 'rails_helper'

RSpec.describe Weight, type: :model do
  describe "relations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:weight_date) }
    it { is_expected.to validate_presence_of(:kg) }
  end
end
