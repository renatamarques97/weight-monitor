require 'rails_helper'

RSpec.describe FatSecretApiService do
  describe '#get_access_token' do
    it 'requests token with provided scope and caches it by scope' do
      service = described_class.new
      http = instance_double(Net::HTTP)
      response = instance_double(Net::HTTPResponse, body: { access_token: 'token-basic', expires_in: 3600 }.to_json)

      expect(Net::HTTP).to receive(:start).once.with('oauth.fatsecret.com', 443, use_ssl: true).and_yield(http)
      expect(http).to receive(:request).once.and_return(response)

      token_1 = service.get_access_token(scope: 'basic')
      token_2 = service.get_access_token(scope: 'basic')

      expect(token_1).to eq('token-basic')
      expect(token_2).to eq('token-basic')
    end

    it 'keeps separate token cache by scope' do
      service = described_class.new
      http = instance_double(Net::HTTP)
      basic_response = instance_double(Net::HTTPResponse, body: { access_token: 'token-basic', expires_in: 3600 }.to_json)
      premier_response = instance_double(Net::HTTPResponse, body: { access_token: 'token-premier', expires_in: 3600 }.to_json)

      expect(Net::HTTP).to receive(:start).twice.with('oauth.fatsecret.com', 443, use_ssl: true).and_yield(http)
      expect(http).to receive(:request).twice.and_return(basic_response, premier_response)

      basic = service.get_access_token(scope: 'basic')
      premier = service.get_access_token(scope: 'premier')

      expect(basic).to eq('token-basic')
      expect(premier).to eq('token-premier')
    end
  end

  describe '#search_foods' do
    it 'calls foods.search.v3 with search_expression and parses JSON response' do
      service = described_class.new
      allow(service).to receive(:get_access_token).with(scope: 'premier').and_return('premier-token')

      http = instance_double(Net::HTTP)
      response_payload = {
        'foods_search' => {
          'results' => {
            'food' => [{ 'food_id' => '1', 'food_name' => 'Banana' }]
          }
        }
      }
      response = instance_double(Net::HTTPResponse, body: response_payload.to_json)

      expect(Net::HTTP).to receive(:start).with('platform.fatsecret.com', 443, use_ssl: true).and_yield(http)
      expect(http).to receive(:request) do |request|
        expect(request['Authorization']).to eq('Bearer premier-token')
        expect(request.uri.query).to include('method=foods.search.v3')
        expect(request.uri.query).to include('search_expression=banana')
        expect(request.uri.query).to include('max_results=10')
        expect(request.uri.query).to include('format=json')
      end.and_return(response)

      result = service.search_foods('banana')
      expect(result).to eq(response_payload)
    end
  end

  describe '#get_food' do
    it 'calls food.get.v5 with food_id and parses JSON response' do
      service = described_class.new
      allow(service).to receive(:get_access_token).with(scope: 'basic').and_return('basic-token')

      http = instance_double(Net::HTTP)
      response_payload = { 'food' => { 'food_id' => '33691', 'food_name' => 'Colby Cheese' } }
      response = instance_double(Net::HTTPResponse, body: response_payload.to_json)

      expect(Net::HTTP).to receive(:start).with('platform.fatsecret.com', 443, use_ssl: true).and_yield(http)
      expect(http).to receive(:request) do |request|
        expect(request['Authorization']).to eq('Bearer basic-token')
        expect(request.uri.query).to include('method=food.get.v5')
        expect(request.uri.query).to include('food_id=33691')
        expect(request.uri.query).to include('format=json')
      end.and_return(response)

      result = service.get_food('33691')
      expect(result).to eq(response_payload)
    end
  end
end
