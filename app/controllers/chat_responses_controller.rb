# frozen_string_literal: true

class ChatResponsesController < ApplicationController
  include ActionController::Live

  before_action :authenticate_user!

  def show
    user_prompt = params[:prompt].to_s.strip
    return head :unprocessable_entity if user_prompt.blank?

    response.headers['Content-type']  = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate
    sse                               = SSE.new(response.stream, event: "message")

    begin
      ::ChatResponseService.new(
        user: current_user,
        prompt: user_prompt,
        objective: params[:objective]
      ).call do |content|
        sse.write({ message: content })
      end
    ensure
      sse.close
    end
  end
end
