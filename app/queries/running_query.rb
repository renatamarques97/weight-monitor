# frozen_string_literal: true

class RunningQuery
  RUNNING_DATE = "runnings.running_date"
  RUNNING_PACE = "runnings.avg_pace"

  def self.runnings(user)
    user.runnings.group(RUNNING_DATE).sum(RUNNING_PACE)
  end
end
