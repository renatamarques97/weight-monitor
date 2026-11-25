# frozen_string_literal: true

# Running#avg_pace changed from a float to a "M'SS\"" string (minutes per distance unit).
# Recompute it for existing runnings so old records show the same format as new ones.
class BackfillRunningAveragePace < ActiveRecord::Migration[8.0]
  RUNNING = 0

  BACKFILL_SQL = <<~SQL.squish
    UPDATE workouts
    SET details = jsonb_set(
      details,
      '{avg_pace}',
      to_jsonb(format('%s''%s"', paces.seconds / 60, lpad((paces.seconds % 60)::text, 2, '0')))
    )
    FROM (
      SELECT id, round((duration * 60 / distance)::numeric)::integer AS seconds
      FROM workouts
      WHERE workout_type = #{RUNNING} AND distance > 0 AND duration IS NOT NULL
    ) AS paces
    WHERE workouts.id = paces.id
  SQL

  def up
    execute BACKFILL_SQL
  end

  def down
    # Irreversible data change: the previous float value was not a meaningful pace.
  end
end
