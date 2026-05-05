require 'rails_helper'

RSpec.describe ChatResponseService do
  let(:user) { create(:user, name: 'Renata Test', email: 'renata@example.com') }
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

    it 'builds user context with diet, meals, weight history and running history' do
      diet = create(:diet,
        user: user,
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 3, 1),
        initial_weight: 80,
        target_weight: 72,
        height: 1.70
      )
      create(:meal, diet: diet, schedule: '2026-01-03 08:00:00', description: 'Eggs and toast', meal_type: 1)
      create(:weight, user: user, weight_date: Date.new(2026, 1, 2), kg: 79.2)
      create(:running, user: user, running_date: Date.new(2026, 1, 2), duration: 30, distance: 5)

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
      expect(system_prompt).to include('distance=5.0')
    end
  end
end
