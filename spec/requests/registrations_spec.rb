require 'rails_helper'

RSpec.describe "User Registrations & Updates", type: :request do
  describe "POST /users" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          user: {
            name: FFaker::Name.name,
            email: FFaker::Internet.email,
            password: "password123",
            password_confirmation: "password123",
            height: 1.82
          }
        }
      end

      it "successfully creates a new user with custom permitted parameters" do
        expect {
          post user_registration_path, params: valid_params
        }.to change(User, :count).by(1)

        new_user = User.last
        expect(new_user.name).to eq(valid_params[:user][:name])
        expect(new_user.height).to eq(1.82)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PUT /users" do
    let(:user) { create(:user, name: FFaker::Name.name, height: 1.70, password: "password123", password_confirmation: "password123") }

    before do
      sign_in user
    end

    context "with valid parameters" do
      let(:update_params) do
        {
          user: {
            name: FFaker::Name.name,
            email: user.email,
            current_password: "password123",
            height: 1.75
          }
        }
      end

      it "successfully updates the user with custom permitted parameters" do
        put user_registration_path, params: update_params

        user.reload
        expect(user.name).to eq(update_params[:user][:name])
        expect(user.height).to eq(1.75)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
