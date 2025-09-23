FactoryBot.define do
  factory :timeline_era, class: 'Timeline::Era' do
    name { "eluvan Era" }
    association :calendar, factory: :timeline_calendar
  end
end
