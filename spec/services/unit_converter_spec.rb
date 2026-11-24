# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnitConverter do
  describe '.convert_weight_between' do
    it 'converts lbs to kg' do
      expect(described_class.convert_weight_between(100, WEIGHTS::LBS, WEIGHTS::KG)).to eq(45.36)
    end

    it 'converts kg to lbs' do
      expect(described_class.convert_weight_between(70, WEIGHTS::KG, WEIGHTS::LBS)).to eq(154.32)
    end

    it 'rounds without converting when units are the same' do
      expect(described_class.convert_weight_between(70.456, WEIGHTS::KG, WEIGHTS::KG)).to eq(70.46)
    end

    it 'returns nil for nil value' do
      expect(described_class.convert_weight_between(nil, WEIGHTS::KG, WEIGHTS::LBS)).to be_nil
    end
  end

  describe '.convert_distance_between' do
    it 'converts mi to km' do
      expect(described_class.convert_distance_between(5, DISTANCES::MI, DISTANCES::KM)).to eq(8.05)
    end

    it 'converts km to mi' do
      expect(described_class.convert_distance_between(10, DISTANCES::KM, DISTANCES::MI)).to eq(6.21)
    end

    it 'returns nil for nil value' do
      expect(described_class.convert_distance_between(nil, DISTANCES::KM, DISTANCES::MI)).to be_nil
    end
  end

  describe '.convert_height_between' do
    it 'converts ft to m' do
      expect(described_class.convert_height_between(6, HEIGHTS::FT, HEIGHTS::M)).to eq(1.83)
    end

    it 'converts m to ft' do
      expect(described_class.convert_height_between(1.75, HEIGHTS::M, HEIGHTS::FT)).to eq(5.74)
    end

    it 'converts m to cm' do
      expect(described_class.convert_height_between(1.75, HEIGHTS::M, HEIGHTS::CM)).to eq(175.0)
    end

    it 'converts cm to ft' do
      expect(described_class.convert_height_between(180, HEIGHTS::CM, HEIGHTS::FT)).to eq(5.91)
    end
  end

  describe '.convert_speed_between' do
    it 'converts mi/h to km/h' do
      expect(described_class.convert_speed_between(10, DISTANCES::MI, DISTANCES::KM)).to eq(16.09)
    end

    it 'converts km/h to mi/h' do
      expect(described_class.convert_speed_between(20, DISTANCES::KM, DISTANCES::MI)).to eq(12.43)
    end
  end

  describe '.convert_time_between' do
    it 'converts minutes to seconds' do
      expect(described_class.convert_time_between(30, TIMES::MINUTES, TIMES::SECONDS)).to eq(1800.0)
    end

    it 'converts seconds to minutes' do
      expect(described_class.convert_time_between(90, TIMES::SECONDS, TIMES::MINUTES)).to eq(1.5)
    end
  end

  describe '.convert' do
    it 'raises for a unit outside the conversion type' do
      expect { described_class.convert(TYPES::HEIGHT, 1, WEIGHTS::KG, HEIGHTS::M) }.to raise_error(KeyError)
    end
  end

  describe '.supports?' do
    it 'accepts known units of the same type' do
      expect(described_class.supports?(TYPES::HEIGHT, HEIGHTS::M, HEIGHTS::FT)).to be(true)
    end

    it 'rejects unknown types' do
      expect(described_class.supports?('unknown', HEIGHTS::M, HEIGHTS::FT)).to be(false)
    end

    it 'rejects units from another type' do
      expect(described_class.supports?(TYPES::HEIGHT, WEIGHTS::KG, HEIGHTS::FT)).to be(false)
    end
  end
end
