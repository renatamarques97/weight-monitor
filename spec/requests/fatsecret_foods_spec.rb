require 'rails_helper'

RSpec.describe '/fatsecret_foods', type: :request do
  describe 'GET /index' do
    it 'returns empty array when query is blank' do
      get fatsecret_foods_url, params: { q: '' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it 'returns food list from foods.food format' do
      service = instance_double(FatSecretApiService)
      allow(FatSecretApiService).to receive(:new).and_return(service)
      allow(service).to receive(:search_foods).with('banana').and_return(
        {
          'foods' => {
            'food' => [
              { 'food_id' => '1', 'food_name' => 'Banana' }
            ]
          }
        }
      )

      get fatsecret_foods_url, params: { q: 'banana' }

      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)
      expect(parsed.first['food_name']).to eq('Banana')
    end

    it 'returns food list from foods_search.results.food format' do
      service = instance_double(FatSecretApiService)
      allow(FatSecretApiService).to receive(:new).and_return(service)
      allow(service).to receive(:search_foods).with('apple').and_return(
        {
          'foods_search' => {
            'results' => {
              'food' => [
                { 'food_id' => '2', 'food_name' => 'Apple' }
              ]
            }
          }
        }
      )

      get fatsecret_foods_url, params: { q: 'apple' }

      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)
      expect(parsed.first['food_name']).to eq('Apple')
    end

    it 'normalizes hash response into array' do
      service = instance_double(FatSecretApiService)
      allow(FatSecretApiService).to receive(:new).and_return(service)
      allow(service).to receive(:search_foods).with('orange').and_return(
        {
          'foods_search' => {
            'results' => {
              'food' => { 'food_id' => '3', 'food_name' => 'Orange' }
            }
          }
        }
      )

      get fatsecret_foods_url, params: { q: 'orange' }

      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)
      expect(parsed).to be_an(Array)
      expect(parsed.first['food_name']).to eq('Orange')
    end

    it 'returns 422 when service responds with API error' do
      service = instance_double(FatSecretApiService)
      allow(FatSecretApiService).to receive(:new).and_return(service)
      allow(service).to receive(:search_foods).with('banana').and_return(
        {
          'error' => { 'message' => 'Missing scope: premier' }
        }
      )

      get fatsecret_foods_url, params: { q: 'banana' }

      expect(response).to have_http_status(:unprocessable_entity)
      parsed = JSON.parse(response.body)
      expect(parsed['error']).to eq('Missing scope: premier')
    end
  end

  describe 'GET /show' do
    it 'returns food details payload' do
      service = instance_double(FatSecretApiService)
      allow(FatSecretApiService).to receive(:new).and_return(service)
      allow(service).to receive(:get_food).with('33691').and_return(
        { 'food' => { 'food_id' => '33691', 'food_name' => 'Colby Cheese' } }
      )

      get fatsecret_food_url('33691')

      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)
      expect(parsed.dig('food', 'food_name')).to eq('Colby Cheese')
    end
  end
end
