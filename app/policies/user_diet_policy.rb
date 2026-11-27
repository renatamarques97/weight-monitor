# frozen_string_literal: true

class UserDietPolicy
  attr_reader :user, :diet

  def initialize(user, diet)
    @user = user
    @diet = diet
  end

  def diet_belongs_to_user?
    user == diet.user
  end

  def view?
    diet_belongs_to_user? || user.account_type_admin? ||
      (user.valid_nutritionist? && diet.user.nutritionist == user)
  end

  def manage?
    user.valid_nutritionist? && diet.nutritionist == user && diet.user.nutritionist == user
  end

  def create?(target_user)
    user.valid_nutritionist? && target_user.nutritionist == user
  end
end
