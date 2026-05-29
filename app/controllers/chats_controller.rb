# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_user!

  PER_PAGE = 5

  def index
    page_data = pagination_data

    @total_pages = page_data[:total_pages]
    @page = page_data[:page]
    @messages = page_data[:messages]
    @serialized_chat_messages = serialized_messages(@messages)

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

  def apply_filter(messages)
    return messages if params[:after_id].blank?

    messages.where(ChatMessage.arel_table[:id].gt(params[:after_id]))
  end

  def pagination_data
    messages = apply_filter(current_user.chat_messages.ordered)

    total = messages.count
    total_pages = [(total.to_f / PER_PAGE).ceil, 1].max
    page = (params[:page] || total_pages).to_i.clamp(1, total_pages)

    messages = messages
                   .offset((page - 1) * PER_PAGE)
                   .limit(PER_PAGE)

    { page:, total_pages:, messages: }
  end

  def serialized_messages(messages)
    messages.map do |msg|
      {
        id: msg.id,
        role: msg.role,
        content: msg.content,
        label: msg.role == 'assistant' ? t('chat.assistant_label') : t('chat.user_label'),
        date: ActionController::Base.helpers.time_ago_in_words(msg.created_at)
      }
    end
  end
end
