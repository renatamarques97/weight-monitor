FactoryBot.define do
  factory :diet do
    start_date { Date.current }
    end_date { Date.current.advance(months: 1) }
    initial_weight { rand(80..100) }
    target_weight { rand(60..79) }
    height { rand(140..200) }
    association :user
  end
end
