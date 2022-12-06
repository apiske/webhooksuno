FactoryBot.define do
  factory :subscription do
    is_public
    workspace
    key { association :key, workspace: workspace }
    router { association :router, workspace: workspace }
    receiver_binding { association :receiver_binding, workspace: workspace }

    destination_url { FFaker::Internet.http_url }
    topic_ids { [] }
    state { Subscription::State.l[:active] }
    destination_type { Subscription::DestinationType.l[:https] }
  end
end
