class CreateDiets < ActiveRecord::Migration[6.0]
  def change
    create_table :diets do |t|
      t.date :start_date, null: false, default: Date.current
      t.date :end_date, null: false, default: Date.current
      t.integer :initial_weight, null: false
      t.integer :target_weight, null: false
      t.float :height
      t.references :user, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
