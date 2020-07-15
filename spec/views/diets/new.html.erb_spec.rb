require 'rails_helper'

RSpec.describe "diets/new", type: :view do
  before(:each) do
    assign(:diet, Diet.new(
      initial_weight: 100,
      target_weight: 80,
      height: 150,
      user: create(:user).id
    ))
  end

  it "renders new diet form" do
    render

    assert_select "form[action=?][method=?]", diets_path, "post" do
      assert_select "input[name=?]", "diet[initial_weight]"
      assert_select "input[name=?]", "diet[target_weight]"
      assert_select "input[name=?]", "diet[height]"
      assert_select "input[name=?]", "diet[user_id]"
    end
  end
end
