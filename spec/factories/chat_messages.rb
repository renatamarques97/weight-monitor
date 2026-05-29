FactoryBot.define do
  factory :chat_message do
    role { :user }
    content { FFaker::Lorem.sentence }
    association :user
  end

  factory :user_chat_message, parent: :chat_message do
    role { :user }
  end

  factory :assistant_chat_message, parent: :chat_message do
    role { :assistant }
  end

end
