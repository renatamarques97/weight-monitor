FactoryBot.define do
  factory :chat_message do
    role { :user }
    content { FFaker::Lorem.sentence }
    association :user
  end
end
