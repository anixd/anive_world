FactoryBot.define do
  factory :tag do
    # .unique поможет избежать конфликтов при создании множества тегов
    name { Faker::Lorem.unique.word }
  end
end
