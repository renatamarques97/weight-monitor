# frozen_string_literal: true

class MakeProfessionalCredentialsGeneric < ActiveRecord::Migration[8.0]
  def up
    add_generic_columns
    backfill_legacy_credentials if legacy_credentials_present?
    remove_country_specific_columns if legacy_credentials_present?
  end

  def down
    add_country_specific_columns
    backfill_country_specific_credentials
    remove_generic_columns
  end

  private

  def legacy_credentials_present?
    column_exists?(:users, :crn) && column_exists?(:users, :cref)
  end

  def add_generic_columns
    change_table :users, bulk: true do |table|
      table.string :country_code unless column_exists?(:users, :country_code)
      table.string :professional_credential unless column_exists?(:users, :professional_credential)
      table.string :professional_registration_number unless column_exists?(:users, :professional_registration_number)
    end
  end

  def backfill_legacy_credentials
    execute(<<~SQL.squish)
      UPDATE users
      SET country_code = 'BR', professional_credential = 'CRN', professional_registration_number = crn
      WHERE professional_type = 0 AND crn IS NOT NULL
    SQL

    execute(<<~SQL.squish)
      UPDATE users
      SET country_code = 'BR', professional_credential = 'CREF', professional_registration_number = cref
      WHERE professional_type = 1 AND cref IS NOT NULL
    SQL
  end

  def remove_country_specific_columns
    change_table :users, bulk: true do |table|
      table.remove :crn
      table.remove :cref
    end
  end

  def add_country_specific_columns
    change_table :users, bulk: true do |table|
      table.string :crn
      table.string :cref
    end
  end

  def backfill_country_specific_credentials
    execute(<<~SQL.squish)
      UPDATE users SET crn = professional_registration_number WHERE professional_credential = 'CRN'
    SQL

    execute(<<~SQL.squish)
      UPDATE users SET cref = professional_registration_number WHERE professional_credential = 'CREF'
    SQL
  end

  def remove_generic_columns
    change_table :users, bulk: true do |table|
      table.remove :country_code
      table.remove :professional_credential
      table.remove :professional_registration_number
    end
  end
end
