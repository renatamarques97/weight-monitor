# frozen_string_literal: true

class ChatResponseService
  def initialize(user:, prompt:, objective: nil, client: nil)
    @user = user
    @prompt = prompt
    @objective = objective
    @client = client || OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'] || ENV.fetch('OPEN_API_KEY', nil))
  end

  def call(&)
    create_user_message
    assistant_response = +''

    begin
      client.chat(parameters: chat_parameters(assistant_response, &))
    ensure
      create_assistant_message(assistant_response)
    end

    assistant_response
  end

  private

  attr_reader :user, :prompt, :objective, :client

  def create_user_message
    user.chat_messages.create!(role: 'user', content: prompt)
  end

  def chat_parameters(assistant_response, &)
    {
      model: ENV.fetch('OPENAI_MODEL', 'gpt-4o-mini'),
      messages: [system_message, *history_messages],
      stream: stream_handler(assistant_response, &)
    }
  end

  def stream_handler(assistant_response, &stream_block)
    proc do |chunk|
      content = chunk.dig('choices', 0, 'delta', 'content')
      next if content.nil?

      assistant_response << content
      stream_block&.call(content)
    end
  end

  def create_assistant_message(assistant_response)
    user.chat_messages.create!(role: 'assistant', content: assistant_response) if assistant_response.present?
  end

  def history_messages
    user.chat_messages.ordered.last(20).map do |msg|
      { role: msg.role, content: msg.content }
    end
  end

  def system_message
    {
      role: 'system',
      content: <<~PROMPT
        #{objective_instructions}
        Use the user data below to respond in an objective, personalized and safe manner.
        If any important data is missing, ask short questions to gather it.

        USER DATA
        #{user_context_for_ai}
      PROMPT
    }
  end

  def objective_instructions
    return weight_loss_instructions if objective == 'weight_loss'
    return hypertrophy_instructions if objective == 'hypertrophy'
    return running_instructions if objective == 'running_performance'

    general_instructions
  end

  def weight_loss_instructions
    'You are an assistant specialized in healthy weight loss. Prioritize caloric deficit, ' \
      'meal quality, hydration and exercise. Be encouraging and practical.'
  end

  def hypertrophy_instructions
    'You are an assistant specialized in muscle hypertrophy. Prioritize controlled caloric ' \
      'surplus, protein intake, progressive overload and recovery. Be technical and motivating.'
  end

  def running_instructions
    'You are an assistant specialized in running performance. Prioritize pace, progressive distance, ' \
      'recovery, hydration and pre/post workout nutrition. Analyze the user running history.'
  end

  def general_instructions
    'You are a health and performance assistant. Analyze the user data holistically and provide ' \
      'balanced guidance on nutrition, exercise and well-being.'
  end

  def user_context_for_ai
    ChatResponseContext.new(user).call
  end
end
