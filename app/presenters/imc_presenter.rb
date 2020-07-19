class ImcPresenter
  def initialize(user)
    @user = user
  end

  def call
    return 0 if weight.nil? || height.nil?
    (weight / (height)**2).round(2)
  end

  private

  attr_reader :user

  def weight
    user.weights.last.try(:kg)
  end

  def height
    user.diets.last.try(:height)
  end
end
