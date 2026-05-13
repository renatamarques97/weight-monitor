class RecentWeightPresenter
  def initialize(user)
    @user = user
  end

  def call
    recent_weight&.kg
  end

  private

  attr_reader :user

  def recent_weight
    user.weights.order(weight_date: :desc, created_at: :desc).first
  end
end
