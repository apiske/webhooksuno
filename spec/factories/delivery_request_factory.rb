FactoryBot.define do
  factory :delivery_request do
    workspace
    topic
    topic_name { topic.name }
    state { DeliveryRequest::State.l[:enqueued] }
    payload_datatype { DeliveryRequest::Datatype.l[:binary] }
    payload { FFaker::HipsterIpsum.paragraphs.join.b }
  end
end
