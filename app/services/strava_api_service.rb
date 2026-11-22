# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

class StravaApiService
  AUTHORIZE_URL = 'https://www.strava.com/oauth/authorize'
  TOKEN_URL = 'https://www.strava.com/oauth/token'
  ACTIVITIES_URL = 'https://www.strava.com/api/v3/athlete/activities'

  class Error < StandardError; end

  def initialize(user)
    @user = user
  end

  def authorization_url(callback_url)
    params = {
      client_id: client_id,
      redirect_uri: callback_url,
      response_type: 'code',
      approval_prompt: 'auto',
      scope: 'activity:read_all'
    }

    "#{AUTHORIZE_URL}?#{URI.encode_www_form(params)}"
  end

  def exchange_code(code)
    response = post_form(TOKEN_URL,
                         client_id: client_id,
                         client_secret: client_secret,
                         code: code,
                         grant_type: 'authorization_code')

    store_tokens(response)
  end

  def access_token
    refresh_token if token_expired?

    @user.strava_access_token
  end

  def activities(per_page: 30, page: 1)
    uri = URI(ACTIVITIES_URL)
    uri.query = URI.encode_www_form(per_page: per_page, page: page)

    response = get(uri, access_token)
    JSON.parse(response.body)
  rescue JSON::ParserError
    raise Error, 'Invalid response received from Strava'
  end

  def refresh_token
    raise Error, 'Strava is not connected' if @user.strava_refresh_token.blank?

    response = post_form(TOKEN_URL,
                         client_id: client_id,
                         client_secret: client_secret,
                         grant_type: 'refresh_token',
                         refresh_token: @user.strava_refresh_token)

    store_tokens(response)
  end

  private

  def client_id
    ENV.fetch('STRAVA_CLIENT_ID')
  end

  def client_secret
    ENV.fetch('STRAVA_CLIENT_SECRET')
  end

  def token_expired?
    @user.strava_token_expires_at.blank? || @user.strava_token_expires_at <= 5.minutes.from_now
  end

  def store_tokens(response)
    raise Error, response['message'] || 'Strava authorization failed' unless response['access_token']

    @user.update!(
      strava_access_token: response['access_token'],
      strava_refresh_token: response['refresh_token'],
      strava_token_expires_at: Time.at(response.fetch('expires_at')).in_time_zone,
      strava_athlete_id: response.dig('athlete', 'id') || @user.strava_athlete_id
    )

    response['access_token']
  end

  def post_form(url, params)
    uri = URI(url)
    response = Net::HTTP.post_form(uri, params)
    parsed = JSON.parse(response.body)

    raise Error, parsed['message'] || "Strava request failed (#{response.code})" unless response.is_a?(Net::HTTPSuccess)

    parsed
  rescue JSON::ParserError
    raise Error, 'Invalid response received from Strava'
  end

  def get(uri, token)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    raise Error, "Strava request failed (#{response.code})" unless response.is_a?(Net::HTTPSuccess)

    response
  end
end
