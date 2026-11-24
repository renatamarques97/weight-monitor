# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UnitConversions', type: :request do
  let(:user) { create(:user) }

  context 'when user is not signed in' do
    it 'still converts, because the sign-up form needs it' do
      get '/unit_conversions/convert', params: { value: '1.75', from_unit: HEIGHTS::M, to_unit: HEIGHTS::FT, type: TYPES::HEIGHT }
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
        get '/unit_conversions/convert', params: { value: '', from_unit: HEIGHTS::M, to_unit: HEIGHTS::FT, type: TYPES::HEIGHT }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq({ 'value' => nil })
      end
    end

    {
      'meters to feet' => [TYPES::HEIGHT, '1.75', HEIGHTS::M, HEIGHTS::FT, 5.74],
      'feet to cm' => [TYPES::HEIGHT, '6', HEIGHTS::FT, HEIGHTS::CM, 182.88],
      'kg to lbs' => [TYPES::WEIGHT, '70', WEIGHTS::KG, WEIGHTS::LBS, 154.32],
      'km to mi' => [TYPES::DISTANCE, '10', DISTANCES::KM, DISTANCES::MI, 6.21],
      'km/h to mi/h' => [TYPES::SPEED, '20', DISTANCES::KM, DISTANCES::MI, 12.43]
    }.each do |description, (type, value, from_unit, to_unit, expected)|
      it "converts #{description}" do
        get '/unit_conversions/convert', params: { value: value, from_unit: from_unit, to_unit: to_unit, type: type }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['value']).to eq(expected)
      end
    end

    context 'with invalid conversion parameters' do
      it 'rejects unknown unit types' do
        get '/unit_conversions/convert', params: { value: '1.80', from_unit: HEIGHTS::M, to_unit: HEIGHTS::FT, type: 'unknown' }
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include('error')
      end

      it 'rejects non-numeric values' do
        get '/unit_conversions/convert', params: { value: '1.80m', from_unit: HEIGHTS::M, to_unit: HEIGHTS::FT, type: TYPES::HEIGHT }
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include('error')
      end

      it 'rejects units that do not match the conversion type' do
        get '/unit_conversions/convert', params: { value: '1.80', from_unit: WEIGHTS::KG, to_unit: HEIGHTS::FT, type: TYPES::HEIGHT }
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include('error')
      end
    end
  end
end
