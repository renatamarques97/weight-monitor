# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnitsHelper, type: :helper do
  let(:user) { build(:user, weight_unit: WEIGHTS::KG, distance_unit: DISTANCES::KM) }

  before do
    signed_in_user = user
    helper.define_singleton_method(:current_user) { signed_in_user }
  end

  describe '#weight_in_preferred_unit' do
    it 'converts to the preferred unit' do
      expect(helper.weight_in_preferred_unit(154.32, WEIGHTS::LBS)).to eq('70 kg')
    end

    it 'keeps decimals that matter' do
      expect(helper.weight_in_preferred_unit(72.35, WEIGHTS::KG)).to eq('72.35 kg')
    end

    it 'shows a dash without a value' do
      expect(helper.weight_in_preferred_unit(nil, WEIGHTS::KG)).to eq('-')
    end
  end

  describe '#distance_in_preferred_unit' do
    it 'converts to the preferred unit' do
      expect(helper.distance_in_preferred_unit(5, DISTANCES::MI)).to eq('8.05 km')
    end
  end

  describe '#speed_in_preferred_unit' do
    it 'converts to the preferred unit per hour' do
      expect(helper.speed_in_preferred_unit(10, DISTANCES::MI)).to eq('16.09 km/h')
    end
  end

  describe '#pace_in_preferred_unit' do
    it 'recomputes the pace for the preferred distance unit' do
      workout = build(:running, duration: 30, distance: 3.1, distance_unit: DISTANCES::MI)
      expect(helper.pace_in_preferred_unit(workout)).to eq(%(6'01"/km))
    end

    it 'is nil without a distance' do
      workout = build(:running, distance: nil)
      expect(helper.pace_in_preferred_unit(workout)).to be_nil
    end
  end

  describe '#height_field_value' do
    it 'shows feet and inches for users in feet' do
      expect(helper.height_field_value(build(:user, height: 5.75, height_unit: HEIGHTS::FT))).to eq(%(5'9"))
    end

    it 'shows the stored number for other units' do
      expect(helper.height_field_value(build(:user, height: 1.75, height_unit: HEIGHTS::M))).to eq(1.75)
    end

    it 'shows what was typed when the height is invalid' do
      invalid_user = build(:user, height: 'tall', height_unit: HEIGHTS::FT)
      invalid_user.validate

      expect(helper.height_field_value(invalid_user)).to eq('tall')
    end
  end

  describe '#height_placeholder' do
    it 'shows the feet and inches format for feet' do
      expect(helper.height_placeholder(HEIGHTS::FT)).to eq(%(5'9"))
    end

    it 'shows the unit otherwise' do
      expect(helper.height_placeholder(HEIGHTS::CM)).to eq(HEIGHTS::CM)
    end
  end

  describe '#unit_label_data' do
    it 'keeps a template with a placeholder for the unit' do
      expect(helper.unit_label_data('distance', 'workout.distance'))
        .to include(unit_label_key: 'distance', unit_label_template: 'Distance (__unit__)')
    end
  end

  describe '#unit_options' do
    it 'pairs translated names with unit codes' do
      expect(helper.unit_options(WEIGHTS::ALL)).to eq([['Kilograms (kg)', WEIGHTS::KG], ['Pounds (lbs)', WEIGHTS::LBS]])
    end
  end
end
