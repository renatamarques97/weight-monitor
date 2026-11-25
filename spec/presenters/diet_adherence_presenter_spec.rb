# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DietAdherencePresenter do
  let(:user) { create(:user) }

  it 'shows not set up without a diet' do
    presenter = described_class.new(user)

    expect(presenter.state).to eq(:not_set)
    expect(presenter.adherence_percent).to be_nil
  end

  it 'shows no recent records with a diet but no diary in the last week' do
    create(:diet, user: user)

    presenter = described_class.new(user)

    expect(presenter.state).to eq(:no_records)
    expect(presenter.adherence_percent).to be_nil
  end

  it 'calculates high adherence for matching meals in the recent week' do
    diet = create(:diet, user: user)
    planned_meal = create(
      :meal,
      diet: diet,
      meal_type: :breakfast,
      schedule: Time.zone.parse('08:00'),
      description: 'Oats with banana'
    )
    create(:meal_food, meal: planned_meal, food_name: 'Oats')
    create(:meal_food, meal: planned_meal, food_name: 'Banana')

    7.times do |index|
      diary = create(:meal_diary, user: user, diary_date: index.days.ago.to_date)
      executed_meal = create(
        :meal,
        meal_diary: diary,
        meal_type: :breakfast,
        schedule: Time.zone.parse('08:10'),
        description: 'Oats with banana'
      )
      create(:meal_food, meal: executed_meal, food_name: 'Oats')
      create(:meal_food, meal: executed_meal, food_name: 'Banana')
    end

    presenter = described_class.new(user)

    expect(presenter.state).to eq(:tracked)
    expect(presenter.adherence_percent).to be_between(95, 100)
  end

  it 'returns low adherence when recent diaries do not follow the plan' do
    diet = create(:diet, user: user)
    planned_meal = create(
      :meal,
      diet: diet,
      meal_type: :breakfast,
      schedule: Time.zone.parse('08:00'),
      description: 'Chicken salad'
    )
    create(:meal_food, meal: planned_meal, food_name: 'Chicken')

    diary = create(:meal_diary, user: user, diary_date: Date.current)
    create(
      :meal,
      meal_diary: diary,
      meal_type: :dinner,
      schedule: Time.zone.parse('20:00'),
      description: 'Pizza'
    )

    presenter = described_class.new(user)

    expect(presenter.state).to eq(:tracked)
    expect(presenter.adherence_percent).to be < 20
  end
end
