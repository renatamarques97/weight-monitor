# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaceFormatter do
  it 'formats minutes and seconds per distance unit' do
    expect(described_class.call(30, 5.2)).to eq(%(5'46"))
  end

  it 'pads seconds' do
    expect(described_class.call(30, 5)).to eq(%(6'00"))
  end

  it 'returns nil without a distance' do
    expect(described_class.call(30, 0)).to be_nil
  end
end
