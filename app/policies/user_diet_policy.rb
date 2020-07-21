class UserDietPolicy
  attr_reader :user, :diet

  def initialize(user, diet)
    @user = user
    @diet = diet
  end

  def diet_belongs_to_user?
    user == diet.user
  end
end
