FactoryBot.define do
  factory :language do
    name { Faker::Nation.language }
    sequence(:code) { |n| "lang#{n}" }

    description { "A sample language description." }

    association :author, factory: :user
  end
end
