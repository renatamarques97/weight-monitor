require 'rails_helper'

RSpec.describe "ChatResponses", type: :request do
  let(:user) { create(:user) }

  describe "GET /chat_responses" do
    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get chat_responses_path, params: { prompt: FFaker::Lorem.sentence }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      before do
        sign_in user
      end

      context "with a blank prompt" do
        it "returns unprocessable entity status" do
          get chat_responses_path, params: { prompt: "" }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "with a valid prompt" do
        let(:service_mock) { instance_double(ChatResponseService) }
        let(:prompt_text) { FFaker::Lorem.sentence }

        it "streams chat response chunks as SSE" do
          expect(ChatResponseService).to receive(:new).with(
            user: user,
            prompt: prompt_text,
            objective: "weight_loss"
          ).and_return(service_mock)

          expect(service_mock).to receive(:call).and_yield("Here is your recipe:").and_yield(" healthy eggs.")

          get chat_responses_path, params: { prompt: prompt_text, objective: "weight_loss" }

          expect(response).to be_successful
          expect(response.headers['Content-Type']).to eq('text/event-stream')
          expect(response.body).to include('data: {"message":"Here is your recipe:"}')
          expect(response.body).to include('data: {"message":" healthy eggs."}')
        end
      end
    end
  end
end
