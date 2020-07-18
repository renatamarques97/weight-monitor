require 'rails_helper'

RSpec.describe "Weights", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/weights/new"
      expect(response).to have_http_status(302)
    end
  end
end
