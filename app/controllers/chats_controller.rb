# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_user!

  PER_PAGE = 5

  def index
    assign_pagination
    respond_to do |format|
      format.html
      format.json { render json: chat_json }
    end
  end

  private

  def apply_filter(messages)
    return messages if params[:after_id].blank?

    messages.where(ChatMessage.arel_table[:id].gt(params[:after_id]))
  end

  def pagination_data
    messages = apply_filter(current_user.chat_messages.ordered)
    total_pages = pagination_total(messages)
    page = pagination_page(total_pages)

    { page:, total_pages:, messages: paginate_messages(messages, page) }
  end

  def pagination_total(messages)
    [(messages.count.to_f / PER_PAGE).ceil, 1].max
  end

  def pagination_page(total_pages)
    (params[:page] || total_pages).to_i.clamp(1, total_pages)
  end

  def paginate_messages(messages, page)
    messages.offset((page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def assign_pagination
    page_data = pagination_data
    @total_pages = page_data[:total_pages]
    @page = page_data[:page]
    @messages = page_data[:messages]
    @serialized_chat_messages = serialized_messages(@messages)
  end

  def chat_json
    { messages_html: rendered_messages, pagination: { page: @page, total_pages: @total_pages } }
  end

  def rendered_messages
    return '' unless @serialized_chat_messages.any?

    render_to_string(partial: 'chats/message', collection: @serialized_chat_messages, as: :message, formats: [:html])
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
