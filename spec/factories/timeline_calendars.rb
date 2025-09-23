FactoryBot.define do
  factory :timeline_calendar, class: 'Timeline::Calendar' do
    sequence(:name) { |n| "Main Calendar #{n}" }
    absolute_year_of_epoch { 5322 }
  end
end
