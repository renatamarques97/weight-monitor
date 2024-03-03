class CreateRunnings < ActiveRecord::Migration[7.1]
  def change
    create_table :runnings do |t|
      t.float :duration, null: false
      t.float :distance, null: false
      t.float :avg_pace
      t.references :user, null: false, index: true, foreign_key: true
      
      t.timestamps
    end
  end
end
