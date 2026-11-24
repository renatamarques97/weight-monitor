# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

WEIGHTS = MeasurementUnits::WEIGHTS
DISTANCES = MeasurementUnits::DISTANCES
HEIGHTS = MeasurementUnits::HEIGHTS
TIMES = MeasurementUnits::TIMES
TYPES = MeasurementUnits::TYPES

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError
  exit 1
end

RSpec.configure do |config|
  # RSpec Rails 8 uses fixture_paths (plural).
  if config.respond_to?(:fixture_paths=)
    config.fixture_paths = [Rails.root.join('spec/fixtures').to_s]
  else
    config.fixture_path = Rails.root.join('spec/fixtures').to_s
  end

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods

  config.include Devise::Test::IntegrationHelpers, type: :request
end
