require 'rails_helper'

RSpec.describe PublishService do
  let(:sender_ws) { create(:workspace, name: 'sender-ws') }
  let(:topic_foo) { create(:topic, workspace: sender_ws, name: 'foo') }
  let(:request_topic) { topic_foo }
  let(:payload) { MultiJson.dump({ foo: 'qux', content: 123 }) }
  let(:tag_a) { create(:tag, workspace: sender_ws, name: 'tag_a') }
  let(:tag_b) { create(:tag, workspace: sender_ws, name: 'tag_b') }
  let(:tag_c) { create(:tag, workspace: sender_ws, name: 'tag_c') }
  let(:exclude_tags) { [tag_a.id, tag_c.id] }
  let(:include_tags) { [tag_b.id] }

  describe '#run' do
    subject(:instance) do
      described_class.new({
        workspace: sender_ws,
        message: payload,
        extra_fields: {},
        topic: request_topic,
        include_tag_ids: include_tags,
        exclude_tag_ids: exclude_tags
      })
    end
    subject(:run) { instance.run }
    subject(:request) { instance.delivery_request }

    it 'creates a delivery request' do
      run

      expect(request.workspace).to eq(sender_ws)
      expect(request.payload_datatype).to eq(DeliveryRequest::Datatype.l[:json])
      expect(request.payload).to eq(payload)
      expect(request.extra_fields).to eq({})
      expect(request.topic).to eq(request_topic)
      expect(request.topic_name).to eq(request_topic.name)

      expect(request.include_tag_ids).to eq(include_tags)
      expect(request.exclude_tag_ids).to eq(exclude_tags)
      expect(request.state).to eq(DeliveryRequest::State.l[:enqueued])
    end
  end
end
