FactoryBot.define do
  factory :receiver_binding do
    is_public
    workspace
    router { association :router, workspace: workspace }
    state { ReceiverBinding::State.l[:enabled] }
  end
end
