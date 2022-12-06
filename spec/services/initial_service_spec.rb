require 'rails_helper'

RSpec.describe WebhookDelivery::InitialService do
  let(:sender_ws) { create(:workspace, name: 'sender-ws') }
  let(:recv_ws) { create(:workspace, name: 'recv-ws') }
  let(:router) { create(:router, workspace: sender_ws, allowed_topic_ids: allowed_topic_ids, tag_ids: router_tags) }
  let!(:receiver) { create(:receiver_binding, workspace: recv_ws, router: router) }
  let(:request) do
    create(:delivery_request, workspace: sender_ws, topic: request_topic, topic_name: request_topic.name,
      exclude_tag_ids: exclude_tags,
      include_tag_ids: include_tags
    )
  end
  let(:topic_foo) { create(:topic, workspace: sender_ws, name: 'foo') }
  let(:topic_bar) { create(:topic, workspace: sender_ws, name: 'bar') }
  let(:request_topic) { topic_foo }
  let(:allowed_topic_ids) { [topic_foo.id, topic_bar.id] }

  let(:router_tags) { [] }
  let(:exclude_tags) { [] }
  let(:include_tags) { [] }

  describe '#run' do
    subject(:run) do
      described_class.new(request.id).run
    end

    before do
      allow(Wh::StatTracker).to receive(:incr)
      allow(Rjob).to receive(:enqueue)
    end

    it 'enqueues fanout' do
      run

      expect(Rjob).to have_received(:enqueue)
        .with(PublishWorker, :fanout, request.id, receiver.id).once
    end

    it 'changes request state to processed' do
      run

      expect(request.reload.state).to eq(DeliveryRequest::State.l[:processed])
    end

    context 'when topic is not in the allow list' do
      let(:allowed_topic_ids) { [topic_bar.id] }

      it 'does not enqueue fanout' do
        run

        expect(Rjob).not_to have_received(:enqueue).with(PublishWorker, :fanout, any_args)
      end
    end

    describe 'tag usage' do
      let!(:tag_a) { create(:tag, workspace: sender_ws, name: 'tag_a') }
      let!(:tag_b) { create(:tag, workspace: sender_ws, name: 'tag_b') }
      let!(:tag_c) { create(:tag, workspace: sender_ws, name: 'tag_c') }

      let(:router_tags) { [tag_a.id, tag_c.id] }

      context 'when no inclusions or exclusions are set' do
        it 'enqueues fanout' do
          run

          expect(Rjob).to have_received(:enqueue)
            .with(PublishWorker, :fanout, request.id, receiver.id).once
        end
      end

      context 'when router is not in include list' do
        let(:include_tags) { [tag_b.id] }

        it 'does not enqueue fanout' do
          run

          expect(Rjob).not_to have_received(:enqueue).with(PublishWorker, :fanout, any_args)
        end
      end

      context 'when router is both in inclusion and exclusion' do
        let(:include_tags) { [tag_a.id] }
        let(:exclude_tags) { [tag_c.id] }

        # exclusion has higher priority than inclusion
        it 'does not enqueue fanout' do
          run

          expect(Rjob).not_to have_received(:enqueue).with(PublishWorker, :fanout, any_args)
        end
      end

      context 'when router has excluded tag' do
        let(:exclude_tags) { [tag_c.id] }

        it 'does not enqueue fanout' do
          run

          expect(Rjob).not_to have_received(:enqueue).with(PublishWorker, :fanout, any_args)
        end
      end
    end
  end
end
