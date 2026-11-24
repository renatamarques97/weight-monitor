# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnitConverter do
  describe '.convert_weight_between' do
    it 'converts lbs to kg' do
      expect(described_class.convert_weight_between(100, Units::WEIGHTS::LBS, Units::WEIGHTS::KG)).to eq(45.36)
    end

    it 'converts kg to lbs' do
      expect(described_class.convert_weight_between(70, Units::WEIGHTS::KG, Units::WEIGHTS::LBS)).to eq(154.32)
    end

    it 'rounds without converting when units are the same' do
      expect(described_class.convert_weight_between(70.456, Units::WEIGHTS::KG, Units::WEIGHTS::KG)).to eq(70.46)
    end

    it 'returns nil for nil value' do
      expect(described_class.convert_weight_between(nil, Units::WEIGHTS::KG, Units::WEIGHTS::LBS)).to be_nil
    end
  end

  describe '.convert_distance_between' do
    it 'converts mi to km' do
      expect(described_class.convert_distance_between(5, Units::DISTANCES::MI, Units::DISTANCES::KM)).to eq(8.05)
    end

    it 'converts km to mi' do
      expect(described_class.convert_distance_between(10, Units::DISTANCES::KM, Units::DISTANCES::MI)).to eq(6.21)
    end

    it 'returns nil for nil value' do
      expect(described_class.convert_distance_between(nil, Units::DISTANCES::KM, Units::DISTANCES::MI)).to be_nil
    end
  end

  describe '.convert_height_between' do
    it 'converts ft to m' do
      expect(described_class.convert_height_between(6, Units::HEIGHTS::FT, Units::HEIGHTS::M)).to eq(1.83)
    end

    it 'converts m to ft' do
      expect(described_class.convert_height_between(1.75, Units::HEIGHTS::M, Units::HEIGHTS::FT)).to eq(5.74)
    end

    it 'converts m to cm' do
      expect(described_class.convert_height_between(1.75, Units::HEIGHTS::M, Units::HEIGHTS::CM)).to eq(175.0)
    end

    it 'converts cm to ft' do
      expect(described_class.convert_height_between(180, Units::HEIGHTS::CM, Units::HEIGHTS::FT)).to eq(5.91)
    end
  end

  describe '.convert_speed_between' do
    it 'converts mi/h to km/h' do
      expect(described_class.convert_speed_between(10, Units::DISTANCES::MI, Units::DISTANCES::KM)).to eq(16.09)
    end

    it 'converts km/h to mi/h' do
      expect(described_class.convert_speed_between(20, Units::DISTANCES::KM, Units::DISTANCES::MI)).to eq(12.43)
    end
  end

  describe '.convert_time_between' do
    it 'converts minutes to seconds' do
      expect(described_class.convert_time_between(30, Units::TIMES::MINUTES, Units::TIMES::SECONDS)).to eq(1800.0)
    end

    it 'converts seconds to minutes' do
      expect(described_class.convert_time_between(90, Units::TIMES::SECONDS, Units::TIMES::MINUTES)).to eq(1.5)
    end
  end

  describe '.convert' do
    it 'raises for a unit outside the conversion type' do
      expect do
        described_class.convert(Units::TYPES::HEIGHT, 1, Units::WEIGHTS::KG, Units::HEIGHTS::M)
      end.to raise_error(KeyError)
    end
  end

  describe 'FACTORS' do
    it 'has a factor for every unit the models accept' do
      {
        Units::TYPES::WEIGHT => Units::WEIGHTS::ALL,
        Units::TYPES::DISTANCE => Units::DISTANCES::ALL,
        Units::TYPES::SPEED => Units::DISTANCES::ALL,
        Units::TYPES::HEIGHT => Units::HEIGHTS::ALL,
        Units::TYPES::TIME => Units::TIMES::ALL
      }.each do |type, units|
        expect(described_class::FACTORS.fetch(type).keys).to match_array(units)
      end
    end
  end

  describe '.supports?' do
    it 'accepts known units of the same type' do
      expect(described_class.supports?(Units::TYPES::HEIGHT, Units::HEIGHTS::M, Units::HEIGHTS::FT)).to be(true)
    end

    it 'rejects unknown types' do
      expect(described_class.supports?('unknown', Units::HEIGHTS::M, Units::HEIGHTS::FT)).to be(false)
    end

    it 'rejects units from another type' do
      expect(described_class.supports?(Units::TYPES::HEIGHT, Units::WEIGHTS::KG, Units::HEIGHTS::FT)).to be(false)
    end
  end
end
