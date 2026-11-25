# frozen_string_literal: true

primary_key = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY', nil)
deterministic_key = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY', nil)
key_derivation_salt = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT', nil)

unless primary_key && deterministic_key && key_derivation_salt
  secret = ENV.fetch('SECRET_KEY_BASE', nil)
  secret ||= Rails.application.secret_key_base if Rails.env.local?

  if secret.present?
    key_generator = ActiveSupport::KeyGenerator.new(secret)
    primary_key ||= key_generator.generate_key('active record encryption primary', 32)
    deterministic_key ||= key_generator.generate_key('active record encryption deterministic', 32)
    key_derivation_salt ||= key_generator.generate_key('active record encryption salt', 32)
  end
end

if primary_key && deterministic_key && key_derivation_salt
  Rails.application.config.active_record.encryption.primary_key = primary_key
  Rails.application.config.active_record.encryption.deterministic_key = deterministic_key
  Rails.application.config.active_record.encryption.key_derivation_salt = key_derivation_salt
  Rails.application.config.active_record.encryption.support_unencrypted_data = true
elsif Rails.env.production?
  raise 'Active Record encryption credentials are missing'
end
