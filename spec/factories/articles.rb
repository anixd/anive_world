FactoryBot.define do
  # Явно указываем класс, так как Article - это STI
  factory :article, class: 'Article' do
    title { Faker::Lorem.sentence(word_count: 3) }
    body { Faker::Lorem.paragraph(sentence_count: 5) }
    published_at { Time.current }

    association :author, factory: :user
  end
end
