FactoryBot.define do
  factory :user do
    name { FFaker::Name.name }
    email { FFaker::Internet.email }
    password { FFaker::Internet.password }
    height { rand(1.5..2.0).round(2) }
  end
end
