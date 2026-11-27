# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/plans', type: :request do
  describe 'GET /plans as a visitor' do
    it 'renders the plan selection without authentication' do
      get plans_path

      expect(response).to be_successful
      expect(response.body).to include(I18n.t('plans.title'))
      expect(response.body).to include(I18n.t('plans.names.free'))
      expect(response.body).to include(I18n.t('plans.names.premium_monthly'))
      expect(response.body).to include(I18n.t('plans.names.premium_semiannual'))
      expect(response.body).to include(I18n.t('plans.names.premium_annual'))
      expect(response.body).to include(I18n.t('plans.names.professional'))
      expect(response.body).to include(I18n.t('plans.features.strava_no'))
      expect(response.body).to include(I18n.t('plans.features.ai_no'))
      expect(response.body).to include(I18n.t('plans.payment_notice'))
    end
  end

  describe 'GET /plans as an authenticated user' do
    it 'renders the plan selection with the view-only CTA' do
      sign_in create(:user)

      get plans_path

      expect(response).to be_successful
      expect(response.body).to include(I18n.t('plans.cta.view'))
      expect(response.body).to include(I18n.t('plans.nav'))
    end
  end
end
