FactoryBot.define do
  factory :user do
    # Используем sequence для гарантии уникальности
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@anive.org" }

    # Используем Faker для более реалистичных данных
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    displayname { "#{firstname} #{lastname}" }

    password { "password123" }
    active { true }

    # "Трейты" для создания пользователей с определенными ролями
    trait :root do
      role { :root }
    end

    trait :owner do
      role { :owner }
    end

    trait :author do
      role { :author }
    end

    trait :editor do
      role { :editor }
    end

    trait :neophyte do
      role { :neophyte }
    end
  end
end
