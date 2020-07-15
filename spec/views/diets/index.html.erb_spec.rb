require 'rails_helper'

RSpec.describe "diets/index", type: :view do
  before(:each) do
    assign(:diets, [
      Diet.create!(
        initial_weight: "Initial Weight",
        target_weight: "Target Weight",
        height: 2,
        user: nil
      ),
      Diet.create!(
        initial_weight: "Initial Weight",
        target_weight: "Target Weight",
        height: 2,
        user: nil
      )
    ])
  end

  it "renders a list of diets" do
    render
    assert_select "tr>td", text: "Initial Weight".to_s, count: 2
    assert_select "tr>td", text: "Target Weight".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
  end
end
