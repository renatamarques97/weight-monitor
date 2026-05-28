require 'rails_helper'

RSpec.describe ChatResponseService do
  let(:user) { create(:user) }
  let(:client) { instance_double(OpenAI::Client) }
  let(:prompt) { 'Build a weekly plan for me' }

  describe '#call' do
    it 'streams chunks and persists user/assistant messages' do
      allow(client).to receive(:chat) do |args|
        stream = args.dig(:parameters, :stream)
        stream.call({ "choices" => [{ "delta" => { "content" => 'First chunk ' } }] })
        stream.call({ "choices" => [{ "delta" => { "content" => 'second chunk' } }] })
      end

      streamed_parts = []
      service = described_class.new(user: user, prompt: prompt, objective: 'general_health', client: client)

      response = service.call { |content| streamed_parts << content }

      expect(response).to eq('First chunk second chunk')
      expect(streamed_parts).to eq(['First chunk ', 'second chunk'])
      expect(user.chat_messages.order(:created_at).pluck(:role, :content)).to eq([
        ['user', prompt],
        ['assistant', 'First chunk second chunk']
      ])
    end

    it 'uses objective-specific instructions in the system prompt' do
      captured_messages = nil
      allow(client).to receive(:chat) do |args|
        captured_messages = args.dig(:parameters, :messages)
        stream = args.dig(:parameters, :stream)
        stream.call({ "choices" => [{ "delta" => { "content" => 'ok' } }] })
      end

      described_class.new(user: user, prompt: prompt, objective: 'running_performance', client: client).call

      system_prompt = captured_messages.first[:content]
      expect(system_prompt).to include('assistant specialized in running performance')
      expect(system_prompt).to include('USER DATA')
    end

    it 'uses hypertrophy-specific instructions when objective is hypertrophy' do
      captured_messages = nil
      allow(client).to receive(:chat) do |args|
        captured_messages = args.dig(:parameters, :messages)
        stream = args.dig(:parameters, :stream)
        stream.call({ "choices" => [{ "delta" => { "content" => 'ok' } }] })
      end

      described_class.new(user: user, prompt: prompt, objective: 'hypertrophy', client: client).call

      system_prompt = captured_messages.first[:content]
      expect(system_prompt).to include('assistant specialized in muscle hypertrophy')
    end

    it 'uses default instructions when objective is unknown' do
      captured_messages = nil
      allow(client).to receive(:chat) do |args|
        captured_messages = args.dig(:parameters, :messages)
        stream = args.dig(:parameters, :stream)
        stream.call({ "choices" => [{ "delta" => { "content" => 'ok' } }] })
      end

      described_class.new(user: user, prompt: prompt, objective: 'unsupported_objective', client: client).call

      system_prompt = captured_messages.first[:content]
      expect(system_prompt).to include('You are a health and performance assistant')
    end

    it 'includes only the latest 20 history messages plus current prompt' do
      25.times do |index|
        create(:chat_message, user: user, role: :user, content: "previous message #{index}")
      end

      captured_messages = nil
      allow(client).to receive(:chat) do |args|
        captured_messages = args.dig(:parameters, :messages)
        stream = args.dig(:parameters, :stream)
        stream.call({ "choices" => [{ "delta" => { "content" => 'ok' } }] })
      end

      described_class.new(user: user, prompt: prompt, objective: 'general_health', client: client).call

      history_messages = captured_messages.drop(1)
      expect(history_messages.size).to eq(20)
      expect(history_messages.last).to include(role: 'user', content: prompt)
      expect(history_messages.map { |msg| msg[:content] }).not_to include('previous message 0')
    end

    it 'does not create assistant message when stream has no content' do
      allow(client).to receive(:chat) do |_args|
      end

      response = described_class.new(user: user, prompt: prompt, objective: 'general_health', client: client).call

      expect(response).to eq('')
      expect(user.chat_messages.order(:created_at).pluck(:role, :content)).to eq([['user', prompt]])
    end

    it 'builds user context with diet, meals, weight history and workout history' do
      user.update(height: 1.70)
      diet = create(:diet,
        user: user,
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 3, 1),
        initial_weight: 80,
        target_weight: 72
      )
      create(:meal, diet: diet, schedule: '2026-01-03 08:00:00', description: 'Eggs and toast', meal_type: 1)
      create(:weight, user: user, weight_date: Date.new(2026, 1, 2), kg: 79.2)
      create(:running, user: user, workout_date: Date.new(2026, 1, 2), duration: 30, distance: 5)

      captured_messages = nil
      allow(client).to receive(:chat) do |args|
        captured_messages = args.dig(:parameters, :messages)
        stream = args.dig(:parameters, :stream)
        stream.call({ "choices" => [{ "delta" => { "content" => 'context-ready' } }] })
      end

      described_class.new(user: user, prompt: prompt, objective: 'weight_loss', client: client).call

      system_prompt = captured_messages.first[:content]
      expect(system_prompt).to include('Current diet: start=2026-01-01, end=2026-03-01')
      expect(system_prompt).to include('Meals in current diet:')
      expect(system_prompt).to include('description=Eggs and toast')
      expect(system_prompt).to include('Weight history (most recent):')
      expect(system_prompt).to include('kg=79.2')
      expect(system_prompt).to include('Running history (most recent):')
      expect(system_prompt).to include('date=2026-01-02')
      expect(system_prompt).to include('distance=5.0')
    end

    it 'builds empty workout sections when user has no workouts' do
      captured_messages = nil
      allow(client).to receive(:chat) do |args|
        captured_messages = args.dig(:parameters, :messages)
        stream = args.dig(:parameters, :stream)
        stream.call({ "choices" => [{ "delta" => { "content" => 'context-ready' } }] })
      end

      described_class.new(user: user, prompt: prompt, objective: 'weight_loss', client: client).call

      system_prompt = captured_messages.first[:content]
      expect(system_prompt).to include('Current diet: not provided')
      expect(system_prompt).to include('Meals: not provided')
      expect(system_prompt).to include('Weight history: empty')
      expect(system_prompt).to include('Running history: empty')
      expect(system_prompt).to include('Yoga history: empty')
      expect(system_prompt).to include('Other history: empty')
    end

    it 'includes details for other workout types in user context' do
      create(:walking, user: user, workout_date: Date.new(2026, 1, 5), duration: 35, distance: 3.0, calories: 190, details: { steps: 1000 })
      create(:yoga, user: user, workout_date: Date.new(2026, 1, 4), duration: 45, calories: 220, details: { style: 'vinyasa' })
      create(:other, user: user, workout_date: Date.new(2026, 1, 3), duration: 20, calories: 120, details: { notes: 'Custom training session' })

      captured_messages = nil
      allow(client).to receive(:chat) do |args|
        captured_messages = args.dig(:parameters, :messages)
        stream = args.dig(:parameters, :stream)
        stream.call({ "choices" => [{ "delta" => { "content" => 'context-ready' } }] })
      end

      described_class.new(user: user, prompt: prompt, objective: 'weight_loss', client: client).call

      system_prompt = captured_messages.first[:content]
      expect(system_prompt).to include('Walking history (most recent):')
      expect(system_prompt).to include('steps=')
      expect(system_prompt).to include('Yoga history (most recent):')
      expect(system_prompt).to include('style=')
      expect(system_prompt).to include('Other history (most recent):')
      expect(system_prompt).to include('notes=')
    end

    it 'includes all workout types in user context' do
      WorkoutType::MAPPING.keys.each_with_index do |type, index|
        create(type, user: user, workout_date: Date.current - index.days, duration: 30 + index, calories: 200 + index)
      end

      captured_messages = nil
      allow(client).to receive(:chat) do |args|
        captured_messages = args.dig(:parameters, :messages)
        stream = args.dig(:parameters, :stream)
        stream.call({ "choices" => [{ "delta" => { "content" => 'context-ready' } }] })
      end

      described_class.new(user: user, prompt: prompt, objective: 'weight_loss', client: client).call

      system_prompt = captured_messages.first[:content]
      WorkoutType::MAPPING.keys.each do |type|
        expect(system_prompt).to include("#{type.to_s.humanize.titleize} history (most recent):")
      end
    end
  end
end
