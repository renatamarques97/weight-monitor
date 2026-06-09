require 'rails_helper'

RSpec.describe UnitConverter do
  def expected_value(value, from_unit, to_unit, precision: 2)
    return nil if value.nil?
    return value.round(precision) if from_unit.to_s == to_unit.to_s
    RubyUnits::Unit.new("#{value} #{from_unit}").convert_to(to_unit.to_s).scalar.to_f.round(precision)
  end

  describe ".convert_weight_between" do
    let(:value) { rand(50.0..150.0).round(2) }

    it "converts lbs → kg" do
      expect(described_class.convert_weight_between(value, WEIGHTS::LBS, WEIGHTS::KG)).to eq(expected_value(value, WEIGHTS::LBS, WEIGHTS::KG))
    end

    it "converts kg → lbs" do
      expect(described_class.convert_weight_between(value, WEIGHTS::KG, WEIGHTS::LBS)).to eq(expected_value(value, WEIGHTS::KG, WEIGHTS::LBS))
    end

    it "is a no-op when units are the same" do
      expect(described_class.convert_weight_between(value, WEIGHTS::KG, WEIGHTS::KG)).to eq(value)
    end

    it "returns nil for nil value" do
      expect(described_class.convert_weight_between(nil, WEIGHTS::KG, WEIGHTS::LBS)).to be_nil
    end
  end

  describe ".convert_distance_between" do
    let(:value) { rand(1.0..50.0).round(2) }

    it "converts mi → km" do
      expect(described_class.convert_distance_between(value, DISTANCES::MI, DISTANCES::KM)).to eq(expected_value(value, DISTANCES::MI, DISTANCES::KM))
    end

    it "converts km → mi" do
      expect(described_class.convert_distance_between(value, DISTANCES::KM, DISTANCES::MI)).to eq(expected_value(value, DISTANCES::KM, DISTANCES::MI))
    end

    it "is a no-op when units are the same" do
      expect(described_class.convert_distance_between(value, DISTANCES::KM, DISTANCES::KM)).to eq(value)
    end

    it "returns nil for nil value" do
      expect(described_class.convert_distance_between(nil, DISTANCES::KM, DISTANCES::MI)).to be_nil
    end
  end

  describe ".convert_height_between" do
    let(:value) { rand(1.0..2.5).round(2) }

    it "converts ft → m" do
      expect(described_class.convert_height_between(value, HEIGHTS::FT, HEIGHTS::M)).to eq(expected_value(value, HEIGHTS::FT, HEIGHTS::M))
    end

    it "converts m → ft" do
      expect(described_class.convert_height_between(value, HEIGHTS::M, HEIGHTS::FT)).to eq(expected_value(value, HEIGHTS::M, HEIGHTS::FT))
    end

    it "converts m → cm" do
      expect(described_class.convert_height_between(value, HEIGHTS::M, HEIGHTS::CM)).to eq(expected_value(value, HEIGHTS::M, HEIGHTS::CM))
    end

    it "converts cm → ft" do
      cm_val = rand(100.0..250.0).round(2)
      expect(described_class.convert_height_between(cm_val, HEIGHTS::CM, HEIGHTS::FT)).to eq(expected_value(cm_val, HEIGHTS::CM, HEIGHTS::FT))
    end

    it "is a no-op when units are the same" do
      expect(described_class.convert_height_between(value, HEIGHTS::M, HEIGHTS::M)).to eq(value)
    end

    it "returns nil for nil value" do
      expect(described_class.convert_height_between(nil, HEIGHTS::M, HEIGHTS::FT)).to be_nil
    end
  end

  describe ".convert_speed_between" do
    let(:value) { rand(10.0..50.0).round(2) }

    it "converts mi/h → km/h" do
      expect(described_class.convert_speed_between(value, DISTANCES::MI, DISTANCES::KM)).to eq(expected_value(value, DISTANCES::MI, DISTANCES::KM))
    end

    it "converts km/h → mi/h" do
      expect(described_class.convert_speed_between(value, DISTANCES::KM, DISTANCES::MI)).to eq(expected_value(value, DISTANCES::KM, DISTANCES::MI))
    end

    it "is a no-op when units are the same" do
      expect(described_class.convert_speed_between(value, DISTANCES::KM, DISTANCES::KM)).to eq(value)
    end

    it "returns nil for nil value" do
      expect(described_class.convert_speed_between(nil, DISTANCES::KM, DISTANCES::MI)).to be_nil
    end
  end

  describe ".convert_time_between" do
    let(:value) { rand(1..120) }

    it "converts minutes to seconds" do
      expect(described_class.convert_time_between(value, TIMES::MINUTES, TIMES::SECONDS)).to eq(expected_value(value, TIMES::MINUTES, TIMES::SECONDS))
    end

    it "converts seconds to minutes" do
      expect(described_class.convert_time_between(value, TIMES::SECONDS, TIMES::MINUTES)).to eq(expected_value(value, TIMES::SECONDS, TIMES::MINUTES))
    end

    it "is a no-op when units are the same" do
      expect(described_class.convert_time_between(value, TIMES::MINUTES, TIMES::MINUTES)).to eq(value.to_f)
    end

    it "returns nil for nil value" do
      expect(described_class.convert_time_between(nil, TIMES::MINUTES, TIMES::SECONDS)).to be_nil
    end
  end
end
