# frozen_string_literal: true

# The Solid Queue tables are now created by CreateSolidQueueTables migration.
# This migration is retained only to preserve migration ordering for databases
# where 20261122200651 was already recorded.
class AddBatchesToSolidQueue < ActiveRecord::Migration[7.1]
end
