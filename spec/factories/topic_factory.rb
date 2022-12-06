FactoryBot.define do
  factory :topic do
    is_public

    workspace

    definition { association :webhook_definition, workspace: workspace }
  end
end
