FactoryBot.define do
  factory :part_of_speech do
    name { Faker::Lorem.word.capitalize }
    sequence(:code) { |n| "pos-#{n}" }

    association :language
    association :author, factory: :user
  end
end
