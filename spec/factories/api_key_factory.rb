FactoryBot.define do
  factory :api_key do
    name { FFaker::Internet.slug }
    workspace

    after(:build) do |obj|
      obj.generate_secret!
    end
  end
end
