# frozen_string_literal: true

class AddRunningDateToRuninng < ActiveRecord::Migration[7.1]
  def change
    add_column :runnings, :running_date, :date, null: false, default: -> { 'CURRENT_DATE' }
  end
end
