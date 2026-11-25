# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeetAndInches do
  describe '.parse' do
    {
      %(5'9") => 5.75,
      %(5' 9) => 5.75,
      '5ft 9in' => 5.75,
      %(5') => 5.0,
      %(6'1.5") => 6.125,
      '5.75' => 5.75
    }.each do |text, feet|
      it "reads #{text} as #{feet} ft" do
        expect(described_class.parse(text)).to eq(feet)
      end
    end

    it 'returns nil for text that is not a height' do
      expect(described_class.parse('tall')).to be_nil
    end
  end

  describe '.display' do
    it 'shows whole inches without decimals' do
      expect(described_class.display(5.75)).to eq(%(5'9"))
    end

    it 'keeps one decimal of an inch' do
      expect(described_class.display(5.77)).to eq(%(5'9.2"))
    end

    it 'carries 12 inches over to the next foot' do
      expect(described_class.display(5.999)).to eq(%(6'0"))
    end

    it 'returns nil without a height' do
      expect(described_class.display(nil)).to be_nil
    end
  end
end
