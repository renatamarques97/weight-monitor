# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_user!

  PER_PAGE = 5

  def index
    page_data = pagination_data

    @total_pages = page_data[:total_pages]
    @page = page_data[:page]
    @serialized_chat_messages = serialized_messages(page_data[:messages])
    rendered_messages = @serialized_chat_messages.any? ? render_to_string(partial: "chats/message", collection: @serialized_chat_messages, as: :message, formats: [:html]) : ""

    respond_to do |format|
      format.html
      format.json do
        render json: {
          messages_html: rendered_messages,
          pagination: {
            page: @page,
            total_pages: @total_pages
          }
        }
      end
    end
  end

  private

  def pagination_data
    total = current_user.chat_messages.count
    total_pages = [(total.to_f / PER_PAGE).ceil, 1].max
    page = (params[:page] || total_pages).to_i.clamp(1, total_pages)

    messages = current_user.chat_messages.ordered
                                 .offset((page - 1) * PER_PAGE)
                                 .limit(PER_PAGE)

    { page:, total_pages:, messages: }
  end

  def serialized_messages(messages)
    messages.map do |msg|
      {
        role: msg.role,
        content: msg.content,
        label: msg.role == 'assistant' ? t('chat.assistant_label') : t('chat.user_label'),
        date: ActionController::Base.helpers.time_ago_in_words(msg.created_at)
      }
    end
  end
end
