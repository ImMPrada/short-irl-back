FactoryBot.define do
  factory :registered_url do
    url { 'https://example.com' }
    active { true }
    expires_at { Time.zone.now + 30.days }
    temporary_session
  end
end
