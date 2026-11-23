# frozen_string_literal: true

class CreateSolidQueueTables < ActiveRecord::Migration[7.1]
  def change
    create_blocked_executions
    create_claimed_executions
    create_failed_executions
    create_jobs
    create_pauses
    create_processes
    create_ready_executions
    create_recurring_executions
    create_recurring_tasks
    create_scheduled_executions
    create_semaphores
    create_batches
    create_batch_executions
    create_foreign_keys
  end

  private

  def create_blocked_executions
    create_table :solid_queue_blocked_executions, if_not_exists: true do |table|
      table.bigint :job_id, null: false
      table.string :queue_name, null: false
      table.integer :priority, default: 0, null: false
      table.string :concurrency_key, null: false
      table.datetime :expires_at, null: false
      table.timestamps
      table.index %i[concurrency_key priority job_id], name: 'index_solid_queue_blocked_executions_for_release'
      table.index %i[expires_at concurrency_key], name: 'index_solid_queue_blocked_executions_for_maintenance'
      table.index :job_id, unique: true
    end
  end

  def create_claimed_executions
    create_table :solid_queue_claimed_executions, if_not_exists: true do |table|
      table.bigint :job_id, null: false
      table.bigint :process_id
      table.timestamps
      table.index :job_id, unique: true
      table.index %i[process_id job_id]
    end
  end

  def create_failed_executions
    create_table :solid_queue_failed_executions, if_not_exists: true do |table|
      table.bigint :job_id, null: false
      table.text :error
      table.timestamps
      table.index :job_id, unique: true
    end
  end

  def create_jobs
    create_table :solid_queue_jobs, if_not_exists: true do |table|
      table.string :queue_name, null: false
      table.string :class_name, null: false
      table.text :arguments
      table.integer :priority, default: 0, null: false
      table.string :active_job_id
      table.datetime :scheduled_at
      table.datetime :finished_at
      table.string :concurrency_key
      table.timestamps
      table.bigint :batch_id
      table.index :active_job_id
      table.index :batch_id
      table.index :class_name
      table.index :finished_at
      table.index %i[queue_name finished_at], name: 'index_solid_queue_jobs_for_filtering'
      table.index %i[scheduled_at finished_at], name: 'index_solid_queue_jobs_for_alerting'
    end
  end

  def create_pauses
    create_table :solid_queue_pauses, if_not_exists: true do |table|
      table.string :queue_name, null: false
      table.timestamps
      table.index :queue_name, unique: true
    end
  end

  def create_processes
    create_table :solid_queue_processes, if_not_exists: true do |table|
      table.string :kind, null: false
      table.datetime :last_heartbeat_at, null: false
      table.bigint :supervisor_id
      table.integer :pid, null: false
      table.string :hostname
      table.text :metadata
      table.timestamps
      table.string :name, null: false
      table.index %i[name supervisor_id], unique: true
      table.index :supervisor_id
      table.index :last_heartbeat_at
    end
  end

  def create_ready_executions
    create_table :solid_queue_ready_executions, if_not_exists: true do |table|
      table.bigint :job_id, null: false
      table.string :queue_name, null: false
      table.integer :priority, default: 0, null: false
      table.timestamps
      table.index :job_id, unique: true
      table.index %i[priority job_id], name: 'index_solid_queue_poll_all'
      table.index %i[queue_name priority job_id], name: 'index_solid_queue_poll_by_queue'
    end
  end

  def create_recurring_executions
    create_table :solid_queue_recurring_executions, if_not_exists: true do |table|
      table.bigint :job_id, null: false
      table.string :task_key, null: false
      table.datetime :run_at, null: false
      table.timestamps
      table.index :job_id, unique: true
      table.index %i[task_key run_at], unique: true
    end
  end

  def create_recurring_tasks
    create_table :solid_queue_recurring_tasks, if_not_exists: true do |table|
      table.string :key, null: false
      table.string :schedule, null: false
      table.string :command, limit: 2048
      table.string :class_name
      table.text :arguments
      table.string :queue_name
      table.integer :priority, default: 0
      table.boolean :static, default: true, null: false
      table.text :description
      table.timestamps
      table.index :key, unique: true
      table.index :static
    end
  end

  def create_scheduled_executions
    create_table :solid_queue_scheduled_executions, if_not_exists: true do |table|
      table.bigint :job_id, null: false
      table.string :queue_name, null: false
      table.integer :priority, default: 0, null: false
      table.datetime :scheduled_at, null: false
      table.timestamps
      table.index :job_id, unique: true
      table.index %i[scheduled_at priority job_id], name: 'index_solid_queue_dispatch_all'
    end
  end

  def create_semaphores
    create_table :solid_queue_semaphores, if_not_exists: true do |table|
      table.string :key, null: false
      table.integer :value, default: 1, null: false
      table.datetime :expires_at, null: false
      table.timestamps
      table.index :expires_at
      table.index %i[key value]
      table.index :key, unique: true
    end
  end

  def create_batches
    create_table :solid_queue_batches, if_not_exists: true do |table|
      table.string :active_job_batch_id
      table.string :description
      table.text :on_finish
      table.text :on_success
      table.text :on_failure
      table.text :metadata
      table.integer :total_jobs, default: 0, null: false
      table.integer :completed_jobs, default: 0, null: false
      table.integer :failed_jobs, default: 0, null: false
      table.datetime :enqueued_at
      table.datetime :finished_at
      table.datetime :failed_at
      table.timestamps
      table.index :active_job_batch_id, unique: true
      table.index :finished_at
    end
  end

  def create_batch_executions
    create_table :solid_queue_batch_executions, if_not_exists: true do |table|
      table.bigint :job_id, null: false
      table.bigint :batch_id, null: false
      table.timestamps
      table.index :job_id, unique: true
      table.index :batch_id
    end
  end

  def create_foreign_keys
    add_queue_foreign_key :solid_queue_batch_executions, :solid_queue_batches, :batch_id
    add_queue_foreign_key :solid_queue_batch_executions, :solid_queue_jobs, :job_id
    add_queue_foreign_key :solid_queue_blocked_executions, :solid_queue_jobs, :job_id
    add_queue_foreign_key :solid_queue_claimed_executions, :solid_queue_processes, :process_id
    add_queue_foreign_key :solid_queue_failed_executions, :solid_queue_jobs, :job_id
    add_queue_foreign_key :solid_queue_ready_executions, :solid_queue_jobs, :job_id
    add_queue_foreign_key :solid_queue_recurring_executions, :solid_queue_jobs, :job_id
    add_queue_foreign_key :solid_queue_scheduled_executions, :solid_queue_jobs, :job_id
  end

  def add_queue_foreign_key(from_table, to_table, column)
    return if foreign_key_exists?(from_table, to_table, column: column)

    add_foreign_key from_table, to_table, column: column, on_delete: :cascade
  end
end
