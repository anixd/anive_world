FactoryBot.define do
  factory :character, class: 'Character' do
    title { Faker::Name.name }
    body { Faker::Lorem.paragraph }
    association :author, factory: :user
  end
end
