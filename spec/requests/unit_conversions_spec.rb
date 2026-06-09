# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UnitConversions', type: :request do
  let(:user) { create(:user) }

  context 'when user is not signed in' do
    it 'redirects to sign in' do
      get '/unit_conversions/convert', params: { value: rand(1.0..2.0).round(2).to_s, from_unit: HEIGHTS::M, to_unit: HEIGHTS::FT, type: TYPES::HEIGHT }
      expect(response).to redirect_to(new_user_session_path)
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
        expect(JSON.parse(response.body)).to eq({ 'value' => nil })
      end
    end

    context 'with height conversion' do
      it 'converts meters to feet' do
        value = rand(1.50..2.10).round(2)
        expected = UnitConverter.convert_height_between(value, HEIGHTS::M, HEIGHTS::FT)

        get '/unit_conversions/convert', params: { value: value.to_s, from_unit: HEIGHTS::M, to_unit: HEIGHTS::FT, type: TYPES::HEIGHT }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['value']).to eq(expected)
      end

      it 'converts feet to cm' do
        value = rand(4.50..7.00).round(2)
        expected = UnitConverter.convert_height_between(value, HEIGHTS::FT, HEIGHTS::CM)

        get '/unit_conversions/convert', params: { value: value.to_s, from_unit: HEIGHTS::FT, to_unit: HEIGHTS::CM, type: TYPES::HEIGHT }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['value']).to eq(expected)
      end
    end

    context 'with weight conversion' do
      it 'converts kg to lbs' do
        value = rand(50.0..120.0).round(2)
        expected = UnitConverter.convert_weight_between(value, WEIGHTS::KG, WEIGHTS::LBS)

        get '/unit_conversions/convert', params: { value: value.to_s, from_unit: WEIGHTS::KG, to_unit: WEIGHTS::LBS, type: TYPES::WEIGHT }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['value']).to eq(expected)
      end
    end

    context 'with distance conversion' do
      it 'converts km to mi' do
        value = rand(1.0..42.2).round(2)
        expected = UnitConverter.convert_distance_between(value, DISTANCES::KM, DISTANCES::MI)

        get '/unit_conversions/convert', params: { value: value.to_s, from_unit: DISTANCES::KM, to_unit: DISTANCES::MI, type: TYPES::DISTANCE }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['value']).to eq(expected)
      end
    end

    context 'with speed conversion' do
      it 'converts km to mi (as speed)' do
        value = rand(5.0..30.0).round(2)
        expected = UnitConverter.convert_speed_between(value, DISTANCES::KM, DISTANCES::MI)

        get '/unit_conversions/convert', params: { value: value.to_s, from_unit: DISTANCES::KM, to_unit: DISTANCES::MI, type: TYPES::SPEED }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['value']).to eq(expected)
      end
    end

    context 'when an error is raised during conversion' do
      it 'handles StandardError gracefully and returns nil' do
        allow(UnitConverter).to receive(:convert_height_between).and_raise(StandardError.new('Conversion error'))
        get '/unit_conversions/convert', params: { value: '1.80', from_unit: HEIGHTS::M, to_unit: HEIGHTS::FT, type: TYPES::HEIGHT }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'value' => nil })
      end
    end
  end
end
