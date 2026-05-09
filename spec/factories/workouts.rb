FactoryBot.define do
  factory :workout do
    association :user
    workout_date { Date.current }
    duration { rand(30..90) }
    calories { duration * rand(6..12) }
    workout_type { :other }

    factory :running, class: 'Running' do
      workout_type { :running }
      distance { rand(5.0..15.0).round(2) }
      details { { avg_pace: (duration / distance).round(2) } }
    end

    factory :walking, class: 'Walking' do
      workout_type { :walking }
      distance { rand(2.0..6.0).round(2) }
      details { { steps: (distance * 1250).to_i } }
    end

    factory :cycling, class: 'Cycling' do
      workout_type { :cycling }
      distance { rand(15.0..40.0).round(2) }
      after(:build) do |workout|
        workout.details.avg_speed = (workout.distance / (workout.duration / 60.0)).round(1) if workout.distance.present?
      end
    end

    factory :swimming, class: 'Swimming' do
      workout_type { :swimming }
      distance { rand(1.0..3.0).round(2) }
      details { { style: Details::Swimming::VALID_STYLES.sample, laps: (distance * 1000 / 25).to_i } }
    end

    factory :weightlifting, class: 'Weightlifting' do
      workout_type { :weightlifting }
      details { { exercises_count: rand(6..12), volume: rand(3000..10000) } }
    end

    factory :yoga, class: 'Yoga' do
      workout_type { :yoga }
      details { { style: Details::Yoga::VALID_STYLES.sample } }
    end

    factory :soccer, class: 'Soccer' do
      workout_type { :soccer }
      details { { goals: rand(0..3), position: %w[Forward Midfielder Defender Goalkeeper].sample } }
    end

    factory :basketball, class: 'Basketball' do
      workout_type { :basketball }
      details { { points: rand(10..40), rebounds: rand(2..15) } }
    end

    factory :tennis, class: 'Tennis' do
      workout_type { :tennis }
      details { { sets_won: rand(0..3), sets_lost: rand(0..3) } }
    end

    factory :martial_arts, class: 'MartialArts' do
      workout_type { :martial_arts }
      details { { style: Details::MartialArts::VALID_STYLES.sample, belt: %w[White Blue Purple Brown Black].sample } }
    end

    factory :other, class: 'Other' do
      workout_type { :other }
      details { { notes: "Custom training session" } }
    end
  end
end
