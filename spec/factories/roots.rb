FactoryBot.define do
  factory :root do
    sequence(:text) { |n| "root#{n}" }
    meaning { Faker::Lorem.sentence }
    published_at { Time.current }

    association :language
    association :author, factory: :user
  end
end
