FactoryBot.define do
  factory :standup do
    user { FactoryBot.create(:user) }
    worklog { Faker::Lorem.paragraph }
  end


  factory :user do
    name {Faker::Name.unique.name}
    email { Faker::Internet.email}
    password {'password'}
    password_confirmation {'password'}
  end
end