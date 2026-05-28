require 'rails_helper'

RSpec.describe "Chats", type: :request do
  let(:user) { create(:user) }

  describe "GET /chats" do
    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get chats_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      before do
        sign_in user
      end

      it "renders a successful HTML response" do
        get chats_path
        expect(response).to be_successful
        expect(response.content_type).to include("text/html")
      end

      it "returns a successful JSON response with paginated and serialized messages" do
        # Create 6 messages (since PER_PAGE is 5, this creates 2 pages)
        create(:chat_message, user: user, role: "user", content: FFaker::Lorem.sentence, created_at: 6.minutes.ago)
        create(:chat_message, user: user, role: "assistant", content: FFaker::Lorem.sentence, created_at: 5.minutes.ago)
        create(:chat_message, user: user, role: "user", content: FFaker::Lorem.sentence, created_at: 4.minutes.ago)
        create(:chat_message, user: user, role: "assistant", content: FFaker::Lorem.sentence, created_at: 3.minutes.ago)
        create(:chat_message, user: user, role: "user", content: FFaker::Lorem.sentence, created_at: 2.minutes.ago)
        create(:chat_message, user: user, role: "assistant", content: FFaker::Lorem.sentence, created_at: 1.minute.ago)

        # Get first page
        get chats_path(page: 1), headers: { "ACCEPT" => "application/json" }
        expect(response).to be_successful
        expect(response.content_type).to include("application/json")

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("messages_html")
        expect(json_response).to have_key("pagination")
        
        pagination = json_response["pagination"]
        expect(pagination["page"]).to eq(1)
        expect(pagination["total_pages"]).to eq(2)
        
        # Test pagination for page 2
        get chats_path(page: 2), headers: { "ACCEPT" => "application/json" }
        expect(response).to be_successful
        
        json_response_p2 = JSON.parse(response.body)
        expect(json_response_p2["pagination"]["page"]).to eq(2)
      end
    end
  end
end
