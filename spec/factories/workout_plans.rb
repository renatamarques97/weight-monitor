# frozen_string_literal: true

FactoryBot.define do
  factory :workout_plan do
    association :user
    association :physical_educator, factory: :user,
                                    account_type: :professional,
                                    professional_type: :physical_educator,
                                    country_code: 'BR',
                                    professional_credential: 'CREF',
                                    professional_registration_number: '456'
    start_date { Date.current }
    end_date { 4.weeks.from_now.to_date }
  end
end
