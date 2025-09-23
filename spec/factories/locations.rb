FactoryBot.define do
  factory :location, class: 'Location' do
    title { Faker::Address.city }
    body { Faker::Lorem.paragraph }
    association :author, factory: :user
  end
end
