FactoryBot.define do
  factory :registered_url do
    url { Faker::Internet.url }
    active { true }
    expires_at { Time.zone.now + 30.days }
    temporary_session
    user
  end
end
