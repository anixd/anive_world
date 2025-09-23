FactoryBot.define do
  factory :history_entry, class: 'HistoryEntry' do
    title { "The Great Battle of #{Faker::Lorem.word}" }
    body { Faker::Lorem.paragraph }
    absolute_year { rand(1000..8000) }
    display_date { "Summer" }

    association :author, factory: :user
    association :era, factory: :timeline_era
  end
end
