FactoryBot.define do
  factory :subscription do
    is_public
    workspace
    key
    router
    receiver_binding

    destination_url { FFaker::Internet.http_url }
    topic_ids { [] }
    state { Subscription::State.l[:active] }
    destination_type { Subscription::DestinationType.l[:https] }
  end
end
