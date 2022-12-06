require 'rails_helper'

RSpec.describe WebhookDelivery::SubService do
  let(:sender_ws) { create(:workspace, name: 'sender-ws') }
  let(:recv_ws) { create(:workspace, name: 'recv-ws') }
  let(:subscription) { create(:subscription, workspace: recv_ws) }
  let(:router) { create(:router, workspace: sender_ws) }
  let(:receiver) { create(:receiver_binding, workspace: recv_ws, router: router) }
  let(:request) { create(:delivery_request, workspace: sender_ws) }
  let(:webhook_definition) { request.topic.definition }

  describe '#run' do
    subject(:run) do
      described_class.new(subscription.id, request.id, receiver.id).run
    end

    before do
      allow(Wh::StatTracker).to receive(:incr)
    end

    it 'creates a message' do
      expect { run }.to change { Message.count }.by(1)

      msg = Message.first!

      expect(msg.sender_workspace).to eq(sender_ws)
      expect(msg.receiver_workspace).to eq(recv_ws)
      expect(msg.delivery_request).to eq(request)
      expect(msg.state).to eq(Message::State.l[:enqueued])
      expect(msg.definition).to eq(webhook_definition)

      expect(Wh::StatTracker).to have_received(:incr)
        .with(recv_ws.id, :message_created).once
    end
  end
end
