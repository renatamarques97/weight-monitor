require 'rails_helper'

RSpec.describe "diets/show", type: :view do
  before(:each) do
    @diet = assign(:diet, Diet.create!(
      initial_weight: 100,
      target_weight: 80,
      height: 200,
      user: create(:user).id
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/100/)
    expect(rendered).to match(/80/)
    expect(rendered).to match(/200/)
  end
end
