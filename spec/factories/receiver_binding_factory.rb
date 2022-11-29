FactoryBot.define do
  factory :receiver_binding do
    is_public
    workspace
    router
    state { ReceiverBinding::State.l[:enabled] }
  end
end
