# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class FatSecretApiService
  TOKEN_URL = 'https://oauth.fatsecret.com/connect/token'
  API_URL = 'https://platform.fatsecret.com/rest/server.api'

  def initialize
    @client_id = ENV.fetch('FATSECRET_CLIENT_ID', nil)
    @client_secret = ENV.fetch('FATSECRET_CLIENT_SECRET', nil)
    @tokens_by_scope = {}
  end

  # Busca alimentos por nome (autocomplete)
  def search_foods(query)
    uri = api_uri(method: 'foods.search.v3', search_expression: query, max_results: 10, format: 'json')
    JSON.parse(request_body(uri, request_for(uri, get_access_token(scope: 'premier'))))
  end

  def get_access_token(scope: 'basic')
    token = cached_token(scope)
    return token if token

    cache_token(scope, request_token(scope))
  end

  # Exemplo: buscar informações de um alimento pelo food_id
  def get_food(food_id)
    uri = api_uri(method: 'food.get.v5', food_id: food_id, format: 'json')
    JSON.parse(request_body(uri, request_for(uri, get_access_token(scope: 'basic'))))
  end

  private

  def api_uri(**params)
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(params)
    uri
  end

  def request_for(uri, token)
    Net::HTTP::Get.new(uri).tap { |request| request['Authorization'] = "Bearer #{token}" }
  end

  def request_body(uri, request)
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }.body
  end

  def cached_token(scope)
    cached = @tokens_by_scope[scope]
    cached[:token] if cached && Time.now < cached[:expires_at]
  end

  def request_token(scope)
    uri = URI(TOKEN_URL)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data('grant_type' => 'client_credentials', 'scope' => scope)
    request.basic_auth(@client_id, @client_secret)
    JSON.parse(request_body(uri, request))
  end

  def cache_token(scope, body)
    token = body['access_token']
    expires_at = Time.now + body.fetch('expires_in', 3600).to_i
    @tokens_by_scope[scope] = { token: token, expires_at: expires_at }
    token
  end
end
