FactoryBot.define do
  factory :message do
    sender_workspace  { create(:workspace) }
    receiver_workspace { create(:workspace) }
    delivery_request { association :delivery_request, workspace: sender_workspace }
    definition { association :webhook_definition, workspace: sender_workspace }

    state { Message::State.l[:enqueued] }
    payload { delivery_request.payload }
  end
end
