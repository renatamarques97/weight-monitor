# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Registrations & Updates', type: :request do
  describe 'POST /users' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            name: FFaker::Name.name,
            email: FFaker::Internet.email,
            password: 'password123',
            password_confirmation: 'password123',
            height: 1.82
          }
        }
      end

      it 'successfully creates a new user with custom permitted parameters' do
        expect do
          post user_registration_path, params: valid_params
        end.to change(User, :count).by(1)

        new_user = User.last
        expect(new_user.name).to eq(valid_params[:user][:name])
        expect(new_user.height).to eq(1.82)
        expect(response).to redirect_to(root_path)
      end

      it 'saves the chosen account type and professional credential' do
        post user_registration_path, params: {
          user: valid_params[:user].merge(
            account_type: 'professional', professional_type: 'nutritionist', country_code: 'BR',
            professional_credential: 'CRN', professional_registration_number: '12345'
          )
        }

        expect(User.last).to have_attributes(
          account_type: 'professional', professional_type: 'nutritionist', country_code: 'BR',
          professional_credential: 'CRN', professional_registration_number: '12345'
        )
      end

      it 'saves the chosen unit preferences' do
        units = { weight_unit: Units::WEIGHTS::LBS, distance_unit: Units::DISTANCES::MI, height_unit: Units::HEIGHTS::FT }
        post user_registration_path, params: { user: valid_params[:user].merge(units, height: 5.97) }

        expect(User.last).to have_attributes(**units, height: 5.97)
      end
    end

    it 'renders the height label with the default unit on the sign-up page' do
      get new_user_registration_path

      expect(response.body).to include("#{I18n.t('preferences.height')} (#{Units::HEIGHTS::M})")
      expect(response.body).to include(%(data-height-converter-label-value="#{I18n.t('preferences.height')}"))
    end
  end

  describe 'GET /users/edit' do
    it 'shows the height of users in feet as feet and inches' do
      sign_in create(:user, height: 5.75, height_unit: Units::HEIGHTS::FT)

      get edit_user_registration_path

      expect(response.body).to include(%(value="#{ERB::Util.html_escape(%(5'9"))}"))
    end
  end

  describe 'PUT /users' do
    let(:user) { create(:user, name: FFaker::Name.name, height: 1.70, password: 'password123', password_confirmation: 'password123') }

    before do
      sign_in user
    end

    context 'with valid parameters' do
      let(:update_params) do
        {
          user: {
            name: FFaker::Name.name,
            email: user.email,
            current_password: 'password123',
            height: 1.75
          }
        }
      end

      it 'successfully updates the user with custom permitted parameters' do
        put user_registration_path, params: update_params

        user.reload
        expect(user.name).to eq(update_params[:user][:name])
        expect(user.height).to eq(1.75)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
