FactoryBot.define do
  factory :topic do
    is_public  

    workspace

    definition { create(:webhook_definition) }
  end
end
