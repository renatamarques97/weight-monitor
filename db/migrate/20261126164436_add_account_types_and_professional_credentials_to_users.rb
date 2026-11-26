# frozen_string_literal: true

class AddAccountTypesAndProfessionalCredentialsToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |table|
      table.integer :account_type, null: false, default: 0
      table.integer :professional_type
      table.string :country_code
      table.string :professional_credential
      table.string :professional_registration_number
      table.index :account_type
    end
  end
end
