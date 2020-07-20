class GoalPresenter
  def initialize(user)
    @user = user
  end

  def achieved?
    return false if last_weight.nil? || target_weight.nil?
    last_weight == target_weight
  end

  private

  attr_reader :user

  def last_weight
    user.weights.last.try(:kg)
  end

  def target_weight
    user.diets.last.try(:target_weight)
  end
end
