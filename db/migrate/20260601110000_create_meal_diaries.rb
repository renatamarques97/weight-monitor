class CreateMealDiaries < ActiveRecord::Migration[8.0]
  def change
    create_table :meal_diaries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :diary_date, null: false
      t.text :notes

      t.timestamps
    end
  end
end
