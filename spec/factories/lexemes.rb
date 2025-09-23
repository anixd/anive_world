FactoryBot.define do
  factory :lexeme do
    spelling { Faker::Lorem.word }

    association :language
    association :author, factory: :user

    # Трейт для удобного создания лексемы сразу со значениями (words)
    trait :with_words do
      # Блок after(:create) выполнится после того, как лексема будет создана
      after(:create) do |lexeme, evaluator|
        # create_list создаст 2 объекта Word, связанных с этой лексемой
        create_list(:word, 4, lexeme: lexeme, author: lexeme.author)
      end
    end
  end
end
