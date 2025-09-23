FactoryBot.define do
  factory :affix do
    sequence(:text) { |n| "-affix#{n}" }
    meaning { Faker::Lorem.sentence }
    affix_type { 'suffix' }
    published_at { Time.current }

    association :language
    association :author, factory: :user
  end
end
