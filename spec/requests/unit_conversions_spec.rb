# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UnitConversions', type: :request do
  let(:user) { create(:user) }

  def convert(value, from_unit, to_unit, type)
    get '/unit_conversions/convert', params: { value: value, from_unit: from_unit, to_unit: to_unit, type: type }
  end

  context 'when user is not signed in' do
    it 'still converts, because the sign-up form needs it' do
      convert('1.75', Units::HEIGHTS::M, Units::HEIGHTS::FT, Units::TYPES::HEIGHT)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['value']).to eq(5.74)
    end
  end

  context 'when user is signed in' do
    before do
      sign_in user
    end

    context 'with blank value' do
      it 'returns nil value' do
        convert('', Units::HEIGHTS::M, Units::HEIGHTS::FT, Units::TYPES::HEIGHT)
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq({ 'value' => nil })
      end
    end

    {
      'meters to feet' => [Units::TYPES::HEIGHT, '1.75', Units::HEIGHTS::M, Units::HEIGHTS::FT, 5.74],
      'feet to cm' => [Units::TYPES::HEIGHT, '6', Units::HEIGHTS::FT, Units::HEIGHTS::CM, 182.88],
      'kg to lbs' => [Units::TYPES::WEIGHT, '70', Units::WEIGHTS::KG, Units::WEIGHTS::LBS, 154.32],
      'km to mi' => [Units::TYPES::DISTANCE, '10', Units::DISTANCES::KM, Units::DISTANCES::MI, 6.21],
      'km/h to mi/h' => [Units::TYPES::SPEED, '20', Units::DISTANCES::KM, Units::DISTANCES::MI, 12.43]
    }.each do |description, (type, value, from_unit, to_unit, expected)|
      it "converts #{description}" do
        convert(value, from_unit, to_unit, type)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['value']).to eq(expected)
      end
    end

    it 'reads feet and inches' do
      convert(%(5'9"), Units::HEIGHTS::FT, Units::HEIGHTS::CM, Units::TYPES::HEIGHT)

      expect(response.parsed_body).to eq('value' => 175.26, 'display' => '175.26')
    end

    it 'shows feet as feet and inches' do
      convert('1.75', Units::HEIGHTS::M, Units::HEIGHTS::FT, Units::TYPES::HEIGHT)

      expect(response.parsed_body).to eq('value' => 5.74, 'display' => %(5'8.9"))
    end

    context 'with invalid conversion parameters' do
      it 'rejects unknown unit types' do
        convert('1.80', Units::HEIGHTS::M, Units::HEIGHTS::FT, 'unknown')
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include('error')
      end

      it 'rejects non-numeric values' do
        convert('1.80m', Units::HEIGHTS::M, Units::HEIGHTS::FT, Units::TYPES::HEIGHT)
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include('error')
      end

      it 'rejects units that do not match the conversion type' do
        convert('1.80', Units::WEIGHTS::KG, Units::HEIGHTS::FT, Units::TYPES::HEIGHT)
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include('error')
      end
    end
  end
end
