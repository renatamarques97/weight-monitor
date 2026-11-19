# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_users_table
    add_users_indexes
  end

  def create_users_table
    create_table :users do |table|
      table.string :email, null: false, default: '', unique: true
      table.string :name, null: false
      table.string :encrypted_password, null: false, default: ''
      table.string :reset_password_token
      table.datetime :reset_password_sent_at
      table.datetime :remember_created_at
      table.timestamps null: false
    end
  end

  def add_users_indexes
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
