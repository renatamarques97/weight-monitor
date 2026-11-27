# frozen_string_literal: true

class CreateProfessionalAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_assignments do |t|
      t.references :client, null: false, foreign_key: { to_table: :users }, index: false
      t.references :nutritionist, null: true, foreign_key: { to_table: :users }
      t.references :physical_educator, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :professional_assignments, :client_id, unique: true
  end
end
