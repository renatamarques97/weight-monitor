FactoryBot.define do
  factory :user do
    name { FFaker::Name.name }
    email { FFaker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    height { rand(1.6..1.9).round(2) }
  end
end
