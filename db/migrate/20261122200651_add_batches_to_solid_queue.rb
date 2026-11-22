# frozen_string_literal: true

class AddBatchesToSolidQueue < ActiveRecord::Migration[7.1]
  def change
    add_job_batch_columns
    create_solid_queue_batches
    create_solid_queue_batch_executions
  end

  private

  def add_job_batch_columns
    add_column :solid_queue_jobs, :batch_id, :bigint, if_not_exists: true
    add_index :solid_queue_jobs, :batch_id, if_not_exists: true
  end

  def create_solid_queue_batches
    create_table :solid_queue_batches, if_not_exists: true do |table|
      add_batch_attributes(table)
      table.timestamps null: false
      add_batch_indexes(table)
    end
  end

  def add_batch_attributes(table)
    table.string :active_job_batch_id
    table.string :description
    add_batch_payload_attributes(table)
    add_batch_counters(table)
  end

  def add_batch_payload_attributes(table)
    table.text :on_finish
    table.text :on_success
    table.text :on_failure
    table.text :metadata
  end

  def add_batch_counters(table)
    table.integer :total_jobs, default: 0, null: false
    table.integer :completed_jobs, default: 0, null: false
    table.integer :failed_jobs, default: 0, null: false
    table.datetime :enqueued_at
    table.datetime :finished_at
    table.datetime :failed_at
  end

  def add_batch_indexes(table)
    table.index :active_job_batch_id, unique: true
    table.index :finished_at
  end

  def create_solid_queue_batch_executions
    create_table :solid_queue_batch_executions, if_not_exists: true do |table|
      table.bigint :job_id, null: false
      table.bigint :batch_id, null: false
      table.datetime :created_at, null: false
      table.index :job_id, unique: true
      table.index :batch_id
      table.foreign_key :solid_queue_batches, column: :batch_id, on_delete: :cascade
      table.foreign_key :solid_queue_jobs, column: :job_id, on_delete: :cascade
    end
  end
end
