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

  shared_context 'with mocked random value' do
    before do
      allow(helper).to receive(:rand).and_return(value)
    end
  end

  shared_examples 'returns placeholder' do
    it 'returns the translated placeholder' do
      expected_placeholder = I18n.t('preferences.placeholder', value:, unit:)
      expect(helper.public_send(method_name, unit)).to eq(expected_placeholder)
    end
  end

  describe '#height_placeholder' do
    include_context 'with mocked random value'

    let(:method_name) { :height_placeholder }

    context 'when unit is feet' do
      let(:unit) { HEIGHTS::FT }
      let(:value) { 5.5 }

      include_examples 'returns placeholder'
    end

    context 'when unit is centimeters' do
      let(:unit) { HEIGHTS::CM }
      let(:value) { 170 }

      include_examples 'returns placeholder'
    end

    context 'when unit is meters' do
      let(:unit) { HEIGHTS::M }
      let(:value) { 1.75 }

      include_examples 'returns placeholder'
    end

    context 'when unit is not recognized' do
      let(:unit) { 'inch' }
      let(:value) { 5.0 }

      include_examples 'returns placeholder'
    end
  end

  describe '#weight_placeholder' do
    include_context 'with mocked random value'

    let(:method_name) { :weight_placeholder }

    context 'when unit is kilograms' do
      let(:unit) { WEIGHTS::KG }
      let(:value) { 70 }

      include_examples 'returns placeholder'
    end

    context 'when unit is pounds' do
      let(:unit) { WEIGHTS::LBS }
      let(:value) { 150 }

      include_examples 'returns placeholder'
    end
  end

  describe '#distance_placeholder' do
    include_context 'with mocked random value'

    let(:method_name) { :distance_placeholder }

    context 'when unit is kilometers' do
      let(:unit) { DISTANCES::KM }
      let(:value) { 10 }

      include_examples 'returns placeholder'
    end

    context 'when unit is miles' do
      let(:unit) { DISTANCES::MI }
      let(:value) { 10 }

      include_examples 'returns placeholder'
    end
  end
end
