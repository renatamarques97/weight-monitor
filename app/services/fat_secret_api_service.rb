# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class FatSecretApiService
  TOKEN_URL = 'https://oauth.fatsecret.com/connect/token'
  API_URL = 'https://platform.fatsecret.com/rest/server.api'

  def initialize
    @client_id = ENV['FATSECRET_CLIENT_ID']
    @client_secret = ENV['FATSECRET_CLIENT_SECRET']
    @tokens_by_scope = {}
  end

  # Busca alimentos por nome (autocomplete)
  def search_foods(query)
    token = get_access_token(scope: 'premier')
    params = {
      method: 'foods.search.v3',
      search_expression: query,
      max_results: 10,
      format: 'json'
    }
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(params)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    JSON.parse(res.body)
  end

  def get_access_token(scope: 'basic')
    cached_token = @tokens_by_scope[scope]
    if cached_token && Time.now < cached_token[:expires_at]
      return cached_token[:token]
    end

    uri = URI(TOKEN_URL)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data({
      'grant_type' => 'client_credentials',
      'scope' => scope
    })
    req.basic_auth(@client_id, @client_secret)

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    body = JSON.parse(res.body)
    token = body['access_token']
    expires_at = Time.now + body.fetch('expires_in', 3600).to_i
    @tokens_by_scope[scope] = { token: token, expires_at: expires_at }

    token
  end

  # Exemplo: buscar informações de um alimento pelo food_id
  def get_food(food_id)
    token = get_access_token(scope: 'basic')
    params = {
      method: 'food.get.v5',
      food_id: food_id,
      format: 'json'
    }
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(params)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    JSON.parse(res.body)
  end
end
