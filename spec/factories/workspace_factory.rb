FactoryBot.define do
  factory :workspace do
    name { FFaker::Internet.slug }
  end
end
