require 'rails_helper'

RSpec.describe "diets/edit", type: :view do
  before(:each) do
    @diet = assign(:diet, Diet.create!(
      initial_weight: 100,
      target_weight: 80,
      height: 150,
      user: create(:user).id
    ))
  end

  it "renders the edit diet form" do
    render

    assert_select "form[action=?][method=?]", diet_path(@diet), "post" do
      assert_select "input[name=?]", "diet[initial_weight]"
      assert_select "input[name=?]", "diet[target_weight]"
      assert_select "input[name=?]", "diet[height]"
    end
  end
end
