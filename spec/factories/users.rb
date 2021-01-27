FactoryBot.define do
  factory :user do
    sequence(:user_name) { Faker::Internet.username(separators: %w[_ -]) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    display_name { "#{first_name} #{last_name}" }
  end
end
