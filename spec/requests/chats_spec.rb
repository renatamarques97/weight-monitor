# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Chats", type: :request do
  let(:user) { create(:user) }

  describe "GET /chats" do
    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get chats_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it "returns 401 Unauthorized for JSON requests" do
        get chats_path, headers: { "ACCEPT" => "application/json" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      before { sign_in user }

      describe "HTML response" do
        it "renders a successful response" do
          get chats_path
          expect(response).to be_successful
          expect(response.content_type).to include("text/html")
        end

        it "renders successfully when the user has no messages" do
          get chats_path
          expect(response).to be_successful
        end
      end

      describe "JSON response structure" do
        before do
          create(:user_chat_message, user: user, created_at: 2.minutes.ago)
          create(:assistant_chat_message, user: user, created_at: 1.minute.ago)
        end

        it "returns the expected top-level keys" do
          get chats_path, headers: { "ACCEPT" => "application/json" }

          expect(response).to be_successful
          expect(response.content_type).to include("application/json")

          json = JSON.parse(response.body)
          expect(json).to have_key("messages_html")
          expect(json).to have_key("pagination")
        end

        it "returns pagination with page and total_pages" do
          get chats_path, headers: { "ACCEPT" => "application/json" }

          pagination = JSON.parse(response.body)["pagination"]
          expect(pagination).to have_key("page")
          expect(pagination).to have_key("total_pages")
        end

        it "includes message HTML content" do
          get chats_path, headers: { "ACCEPT" => "application/json" }

          html = JSON.parse(response.body)["messages_html"]
          expect(html).not_to be_empty
        end
      end

      describe "pagination" do
        # PER_PAGE = 5, so 6 messages create 2 pages
        let!(:messages) do
          (1..6).map do |i|
            create(:user_chat_message, user: user, created_at: (7 - i).minutes.ago)
          end
        end

        it "defaults to the last page when no page param is given" do
          get chats_path, headers: { "ACCEPT" => "application/json" }

          pagination = JSON.parse(response.body)["pagination"]
          expect(pagination["total_pages"]).to eq(2)
          expect(pagination["page"]).to eq(2)
        end

        it "returns page 1 when explicitly requested" do
          get chats_path(page: 1), headers: { "ACCEPT" => "application/json" }

          pagination = JSON.parse(response.body)["pagination"]
          expect(pagination["page"]).to eq(1)
          expect(pagination["total_pages"]).to eq(2)
        end

        it "returns page 2 when explicitly requested" do
          get chats_path(page: 2), headers: { "ACCEPT" => "application/json" }

          pagination = JSON.parse(response.body)["pagination"]
          expect(pagination["page"]).to eq(2)
        end

        it "clamps an out-of-range page to the maximum" do
          get chats_path(page: 999), headers: { "ACCEPT" => "application/json" }

          pagination = JSON.parse(response.body)["pagination"]
          expect(pagination["page"]).to eq(2)
        end

        it "clamps a page below 1 to 1" do
          get chats_path(page: 0), headers: { "ACCEPT" => "application/json" }

          pagination = JSON.parse(response.body)["pagination"]
          expect(pagination["page"]).to eq(1)
        end
      end

      describe "after_id filtering" do
        let!(:msg1) { create(:user_chat_message, user: user, created_at: 5.minutes.ago) }
        let!(:msg2) { create(:assistant_chat_message, user: user, created_at: 4.minutes.ago) }
        let!(:msg3) { create(:user_chat_message, user: user, created_at: 3.minutes.ago) }
        let!(:msg4) { create(:assistant_chat_message, user: user, created_at: 2.minutes.ago) }

        it "returns only messages with id greater than after_id" do
          get chats_path(after_id: msg2.id), headers: { "ACCEPT" => "application/json" }

          expect(response).to be_successful
          html = JSON.parse(response.body)["messages_html"]
          expect(html).to include(msg3.content)
          expect(html).to include(msg4.content)
          expect(html).not_to include(msg1.content)
          expect(html).not_to include(msg2.content)
        end

        it "returns an empty messages_html when after_id is the last message" do
          get chats_path(after_id: msg4.id), headers: { "ACCEPT" => "application/json" }

          html = JSON.parse(response.body)["messages_html"]
          expect(html).to be_empty
        end

        it "returns all messages when after_id is not provided" do
          get chats_path, headers: { "ACCEPT" => "application/json" }

          # With 4 messages and PER_PAGE=5, all fit on one page
          pagination = JSON.parse(response.body)["pagination"]
          expect(pagination["total_pages"]).to eq(1)
        end

        it "returns all messages after after_id regardless of pagination" do
          get chats_path(after_id: msg1.id), headers: { "ACCEPT" => "application/json" }

          html = JSON.parse(response.body)["messages_html"]
          # msg2, msg3, msg4 should all appear
          expect(html).to include(msg2.content)
          expect(html).to include(msg3.content)
          expect(html).to include(msg4.content)
        end

        it "does not leak messages from other users" do
          other_user = create(:user)
          other_msg = create(:user_chat_message, user: other_user, created_at: 1.minute.ago)

          get chats_path(after_id: msg1.id), headers: { "ACCEPT" => "application/json" }

          html = JSON.parse(response.body)["messages_html"]
          expect(html).not_to include(other_msg.content)
        end
      end

      describe "message isolation between users" do
        it "does not show messages from other users" do
          other_user = create(:user)
          own_msg = create(:user_chat_message, user: user)
          other_msg = create(:assistant_chat_message, user: other_user)

          get chats_path, headers: { "ACCEPT" => "application/json" }

          html = JSON.parse(response.body)["messages_html"]
          expect(html).to include(own_msg.content)
          expect(html).not_to include(other_msg.content)
        end
      end
    end
  end
end
