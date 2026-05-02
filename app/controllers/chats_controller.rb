# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chat_messages = current_user.chat_messages.ordered.last(40)
  end
end
