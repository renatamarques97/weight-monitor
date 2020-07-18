class CreateWeights < ActiveRecord::Migration[6.0]
  def change
    create_table :weights do |t|
      t.float :kg, null: false
      t.date :weight_date, null:false, default: Date.current
      t.references :user, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
