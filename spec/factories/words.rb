FactoryBot.define do
  factory :word do
    definition { Faker::Lorem.sentence }
    transcription { "[#{Faker::Lorem.word}]" }

    association :author, factory: :user
    association :lexeme
  end
end
