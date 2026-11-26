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
    diet = create(:diet, user: user)
    planned_meal = create(
      :meal,
      diet: diet,
      meal_type: :breakfast,
      schedule: Time.zone.parse('08:00'),
      description: 'Breakfast'
    )
    create(:meal_food, meal: planned_meal, food_name: 'Oats')

    presenter = described_class.new(user)

    expect(presenter.state).to eq(:no_records)
    expect(presenter.adherence_percent).to be_nil
  end

  it 'shows no plan when the diet has no meals' do
    create(:diet, user: user)

    presenter = described_class.new(user)

    expect(presenter.state).to eq(:no_plan)
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

  it 'gives matching food a higher score when the meal type is the same' do
    diet = create(:diet, user: user)
    planned_meal = create(
      :meal,
      diet: diet,
      meal_type: :breakfast,
      schedule: Time.zone.parse('08:00'),
      description: 'Morning meal'
    )
    create(:meal_food, meal: planned_meal, food_name: 'Pão')

    diary = create(:meal_diary, user: user, diary_date: Date.current)
    executed_meal = create(
      :meal,
      meal_diary: diary,
      meal_type: :breakfast,
      schedule: Time.zone.parse('08:10'),
      description: 'Quick breakfast'
    )
    create(:meal_food, meal: executed_meal, food_name: 'Pao')

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

  it 'returns zero when the meal type matches but no planned food was eaten' do
    diet = create(:diet, user: user)
    planned_meal = create(
      :meal,
      diet: diet,
      meal_type: :breakfast,
      schedule: Time.zone.parse('08:00'),
      description: 'Breakfast'
    )
    create(:meal_food, meal: planned_meal, food_name: 'Chicken')

    diary = create(:meal_diary, user: user, diary_date: Date.current)
    executed_meal = create(
      :meal,
      meal_diary: diary,
      meal_type: :breakfast,
      schedule: Time.zone.parse('08:10'),
      description: 'Breakfast'
    )
    create(:meal_food, meal: executed_meal, food_name: 'Pizza')

    presenter = described_class.new(user)

    expect(presenter.state).to eq(:tracked)
    expect(presenter.adherence_percent).to eq(0)
  end

  it 'does not reuse an eaten food for another meal type in the plan' do
    diet = create(:diet, user: user)

    breakfast = create(
      :meal,
      diet: diet,
      meal_type: :breakfast,
      schedule: Time.zone.parse('08:00'),
      description: 'Breakfast'
    )
    create(:meal_food, meal: breakfast, food_name: 'Eggs')

    lunch = create(
      :meal,
      diet: diet,
      meal_type: :lunch,
      schedule: Time.zone.parse('12:00'),
      description: 'Lunch'
    )
    create(:meal_food, meal: lunch, food_name: 'Eggs')

    diary = create(:meal_diary, user: user, diary_date: Date.current)
    breakfast_record = create(
      :meal,
      meal_diary: diary,
      meal_type: :breakfast,
      schedule: Time.zone.parse('08:10'),
      description: 'Breakfast'
    )
    create(:meal_food, meal: breakfast_record, food_name: 'Eggs')

    presenter = described_class.new(user)

    expect(presenter.state).to eq(:tracked)
    expect(presenter.adherence_percent).to eq(49)
  end
end
