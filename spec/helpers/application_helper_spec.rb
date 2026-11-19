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
end
