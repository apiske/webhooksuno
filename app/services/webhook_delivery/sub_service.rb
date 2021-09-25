# frozen_string_literal: true

class WebhookDelivery::SubService
  attr_reader :request

  def initialize(subscription_id, request_id, receiver_id)
    @receiver = ReceiverBinding
      .eager_load(:binding_request)
      .eager_load(:workspace)
      .find(receiver_id)
    @sender_workspace_id = @receiver.binding_request.workspace_id
    @workspace = @receiver.workspace
    @subscription = Subscription.find(subscription_id)
    @request = DeliveryRequest.find(request_id)
  end

  def run
    msg = create_base_message
    msg.payload = @request.payload

    msg.save!

    Rjob.enqueue(PublishWorker, :dispatch, msg.id, @subscription.id)

    Wh::StatTracker.incr(@workspace.id, :message_created)
  end

  def create_base_message
    Message.new(
      sender_workspace_id: @sender_workspace_id,
      receiver_workspace_id: @workspace.id,
      delivery_request: @request,
      state: Message::State.l[:enqueued]
    )
  end
end
