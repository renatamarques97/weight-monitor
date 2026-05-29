# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatMessage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:content) }

    it "accepts 'user' as a valid role" do
      msg = build(:user_chat_message)
      expect(msg).to be_valid
    end

    it "accepts 'assistant' as a valid role" do
      msg = build(:assistant_chat_message)
      expect(msg).to be_valid
    end

    it "rejects an unknown role" do
      msg = build(:chat_message, role: "robot")
      expect(msg).not_to be_valid
      expect(msg.errors[:role]).to be_present
    end
  end

  describe "factories" do
    it "creates a valid :chat_message with default user role" do
      msg = create(:chat_message)
      expect(msg).to be_persisted
      expect(msg.role).to eq("user")
    end

    it "creates a valid :user_chat_message" do
      msg = create(:user_chat_message)
      expect(msg).to be_persisted
      expect(msg.role).to eq("user")
    end

    it "creates a valid :assistant_chat_message" do
      msg = create(:assistant_chat_message)
      expect(msg).to be_persisted
      expect(msg.role).to eq("assistant")
    end
  end

  describe ".ordered scope" do
    let(:user) { create(:user) }

    it "returns messages ordered by created_at ascending" do
      msg1 = create(:user_chat_message, user: user, created_at: 3.minutes.ago)
      msg2 = create(:assistant_chat_message, user: user, created_at: 2.minutes.ago)
      msg3 = create(:user_chat_message, user: user, created_at: 1.minute.ago)

      expect(ChatMessage.ordered.to_a).to eq([msg1, msg2, msg3])
    end

    it "uses id as a tiebreaker when created_at values are equal" do
      now = Time.current
      msg_a = create(:user_chat_message, user: user, created_at: now)
      msg_b = create(:assistant_chat_message, user: user, created_at: now)

      ordered = ChatMessage.ordered.to_a
      expect(ordered.index(msg_a)).to be < ordered.index(msg_b)
    end
  end
end
