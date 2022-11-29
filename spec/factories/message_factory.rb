FactoryBot.define do
  factory :message do
    sender_workspace { create(:workspace) }
    receiver_workspace { create(:workspace) }
    delivery_request
    definition { create(:webhook_definition) }

    state { Message::State.l[:enqueued] }
    payload { delivery_request.payload }
  end
end
