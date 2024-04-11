# frozen_string_literal: true

class ChatResponsesController < ApplicationController
  include ActionController::Live

  def show
    response.headers['Content-type']  = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate
    sse                               = SSE.new(response.stream, event: "message")
    client                            = OpenAI::Client.new(access_token: ENV["OPEN_API_KEY"])

    begin
      client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: params[:prompt] }],
          stream: proc do |chunk|
            content = chunk.dig("choices", 0, "delta", "content")
            return if content.nil?
            sse.write({ message: content })
          end
        }
      )
    ensure
      sse.close
    end
  end
end
