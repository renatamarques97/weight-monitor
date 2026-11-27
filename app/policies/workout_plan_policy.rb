# frozen_string_literal: true

class WorkoutPlanPolicy
  attr_reader :user, :plan

  def initialize(user, plan)
    @user = user
    @plan = plan
  end

  def view?
    plan.user == user || user.account_type_admin? ||
      (user.valid_physical_educator? && plan.user.physical_educator == user)
  end

  def manage?
    user.valid_physical_educator? && plan.physical_educator == user &&
      plan.user.physical_educator == user
  end

  def create?(target_user)
    user.valid_physical_educator? && target_user.physical_educator == user
  end
end
