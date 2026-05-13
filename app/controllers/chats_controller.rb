# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_user!

  PER_PAGE = 5

  def index
    total = current_user.chat_messages.count
    @total_pages = [(total.to_f / PER_PAGE).ceil, 1].max
    @page = (params[:page] || @total_pages).to_i.clamp(1, @total_pages)
    @chat_messages = current_user.chat_messages.ordered
                                               .offset((@page - 1) * PER_PAGE)
                                               .limit(PER_PAGE)
  end
end
