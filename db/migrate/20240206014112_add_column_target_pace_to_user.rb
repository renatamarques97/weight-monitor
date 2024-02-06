class AddColumnTargetPaceToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :target_pace, :float
  end
end
