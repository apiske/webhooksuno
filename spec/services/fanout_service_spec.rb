require 'rails_helper'

RSpec.describe WebhookDelivery::FanoutService do
  let(:sender_ws) { create(:workspace, name: 'sender-ws') }
  let(:recv_ws) { create(:workspace, name: 'recv-ws') }

  let(:topic_foo) { create(:topic, workspace: sender_ws, name: 'foo') }
  let(:topic_bar) { create(:topic, workspace: sender_ws, name: 'bar') }
  let(:topic_qux) { create(:topic, workspace: sender_ws, name: 'qux') }

  let(:allowed_topic_ids) do
    [
      topic_foo.id,
      topic_bar.id,
      topic_qux.id
    ]
  end

  let(:sub_01_topics) { [topic_foo.id] }
  let(:sub_02_topics) { [topic_bar.id, topic_qux.id] }
  let(:sub_02_state) { Subscription::State.l[:active] }
  let(:request_topic) { topic_bar }

  let(:subscription_01) { create(:subscription, workspace: recv_ws, router: router, topic_ids: sub_01_topics) }
  let(:subscription_02) { create(:subscription, workspace: recv_ws, router: router, topic_ids: sub_02_topics, state: sub_02_state) }
  let(:other_subscription) { create(:subscription) }

  let(:router) { create(:router, workspace: sender_ws, allowed_topic_ids: allowed_topic_ids) }
  let(:receiver) { create(:receiver_binding, workspace: recv_ws, router: router) }

  let(:request) { create(:delivery_request, workspace: sender_ws, topic: request_topic, topic_name: request_topic.name) }

  describe '#run' do
    subject(:run) do
      described_class.new(request.id, receiver.id).run
    end

    before do
      allow(Wh::StatTracker).to receive(:incr)
      allow(Rjob).to receive(:enqueue)

      subscription_01
      subscription_02
      other_subscription
    end

    it 'enqueues publish jobs for matching subscriptions' do
      run

      expect(Rjob).to have_received(:enqueue)
        .with(PublishWorker, :sub, subscription_02.id, request.id, receiver.id).once
      expect(Rjob).not_to have_received(:enqueue)
        .with(PublishWorker, :sub, subscription_01.id, any_args)
      expect(Rjob).not_to have_received(:enqueue)
        .with(PublishWorker, :sub, other_subscription.id, any_args)

      expect(Wh::StatTracker).to have_received(:incr).with(recv_ws.id, :request_fanout).once
    end

    context 'when subscription is in disabled' do
      let(:sub_02_state) { Subscription::State.l[:disabled] }

      it 'does not enqueue subscription' do
        run

        expect(Rjob).not_to have_received(:enqueue)
          .with(PublishWorker, :sub, subscription_02.id, any_args)
      end
    end

    context 'when subscription is in unverified' do
      let(:sub_02_state) { Subscription::State.l[:unverified] }

      it 'enqueues the subscription' do
        run

        expect(Rjob).to have_received(:enqueue)
          .with(PublishWorker, :sub, subscription_02.id, request.id, receiver.id).once
      end
    end

    context 'when subscription is in error' do
      let(:sub_02_state) { Subscription::State.l[:error] }

      it 'does not enqueue subscription' do
        run

        expect(Rjob).not_to have_received(:enqueue)
          .with(PublishWorker, :sub, subscription_02.id, any_args)
      end
    end

    context 'more than one subscription match' do
      let(:sub_02_topics) { [topic_bar.id, topic_qux.id, topic_foo.id] }
      let(:request_topic) { topic_foo }

      it 'also enqueues the other subscription' do
        run

        expect(Rjob).to have_received(:enqueue)
          .with(PublishWorker, :sub, subscription_02.id, request.id, receiver.id).once
        expect(Rjob).to have_received(:enqueue)
          .with(PublishWorker, :sub, subscription_01.id, request.id, receiver.id).once
      end
    end

  end
end
