class CreateWorkouts < ActiveRecord::Migration[8.0]
  def change
    create_table :workouts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :workout_type, null: false, default: 0
      t.date :workout_date, null: false
      t.float :duration, null: false
      t.float :distance
      t.integer :calories
      t.jsonb :details, default: {}, null: false

      t.timestamps
    end

    drop_table :runnings do |t|
      t.float :duration, null: false
      t.float :distance, null: false
      t.float :avg_pace
      t.references :user, null: false, foreign_key: true
      t.date :running_date, null: false
      t.timestamps
    end
  end
end