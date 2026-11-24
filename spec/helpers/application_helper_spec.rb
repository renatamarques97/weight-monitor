# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#app_version' do
    context 'when APP_VERSION env var is not set' do
      before { allow(ENV).to receive(:[]).with('APP_VERSION').and_return(nil) }

      it 'returns default version 1.0.0' do
        expect(helper.app_version).to eq('1.0.0')
      end
    end

    context 'when APP_VERSION env var is set' do
      let(:random_version) { "#{rand(1..10)}.#{rand(0..20)}.#{rand(0..20)}" }

      before { allow(ENV).to receive(:[]).with('APP_VERSION').and_return(random_version) }

      it 'returns the value of APP_VERSION' do
        expect(helper.app_version).to eq(random_version)
      end
    end
  end

  describe '#app_build_date' do
    context 'when BUILD_DATE env var is not set' do
      before { allow(ENV).to receive(:[]).with('BUILD_DATE').and_return(nil) }

      it 'returns today date string' do
        expect(helper.app_build_date).to eq(Time.current.to_date.to_s)
      end
    end

    context 'when BUILD_DATE env var is set' do
      let(:random_date) { (Date.current - rand(1..365).days).to_s }

      before { allow(ENV).to receive(:[]).with('BUILD_DATE').and_return(random_date) }

      it 'returns the value of BUILD_DATE' do
        expect(helper.app_build_date).to eq(random_date)
      end
    end
  end

  describe '#render_chat_markdown' do
    it 'returns an empty string for blank content' do
      expect(helper.render_chat_markdown(nil)).to eq('')
    end

    it 'renders headings, paragraphs, emphasis, and lists' do
      markdown = <<~MARKDOWN
        ### Refeições

        - **Café da manhã:** Iogurte
        - _Almoço:_ Frango

        Texto normal com *ênfase* e __negrito__.
      MARKDOWN

      html = helper.render_chat_markdown(markdown)

      expect(html).to include('<h3>Refeições</h3>')
      expect(html).to include('<li><strong>Café da manhã:</strong> Iogurte</li>')
      expect(html).to include('<li><em>Almoço:</em> Frango</li>')
      expect(html).to include('<em>ênfase</em>')
      expect(html).to include('<strong>negrito</strong>')
      expect(html).to include('<ul>')
    end

    it 'renders H1 and H2 headings' do
      html = helper.render_chat_markdown("# Título\n\n## Subtítulo")

      expect(html).to include('<h1>Título</h1>')
      expect(html).to include('<h2>Subtítulo</h2>')
    end

    it 'escapes HTML from the Markdown content' do
      html = helper.render_chat_markdown('<script>alert("unsafe")</script>')

      expect(html).not_to include('<script>')
      expect(html).to include('&lt;script&gt;')
    end

    it 'does not treat a fourth-level heading as a heading' do
      html = helper.render_chat_markdown('#### Texto')

      expect(html).to include('<p>#### Texto</p>')
    end
  end

  describe '#weight_trend_direction' do
    it 'marks weight loss as positive when the target is lower' do
      expect(helper.weight_trend_direction(-2.0, 90, 80)).to eq('positive')
    end

    it 'marks weight gain as positive when the target is higher' do
      expect(helper.weight_trend_direction(2.0, 70, 80)).to eq('positive')
    end

    it 'marks movement away from the target as negative' do
      expect(helper.weight_trend_direction(2.0, 90, 80)).to eq('negative')
    end

    it 'returns neutral when there is no weight change' do
      expect(helper.weight_trend_direction(0, 90, 80)).to eq('neutral')
    end

    it 'returns neutral without goal bounds' do
      expect(helper.weight_trend_direction(-2.0, nil, 80)).to eq('neutral')
    end
  end
end
