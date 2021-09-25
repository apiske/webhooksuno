# frozen_string_literal: true

class WebhookDelivery::FanoutService
  attr_reader :request

  def initialize(request_id, receiver_id)
    @receiver = ReceiverBinding
      .eager_load(:workspace)
      .find(receiver_id)
    @workspace = @receiver.workspace
    @request = DeliveryRequest.find(request_id)
  end

  def run
    subscriptions = fetch_subscriptions.select(:id)
    subscriptions.each do |sub|
      Rjob.enqueue(PublishWorker, :sub, sub.id, @request.id, @receiver.id)
    end

    Wh::StatTracker.incr(@workspace.id, :request_fanout)
  end

  private

  def fetch_subscriptions
    @workspace
      .subscriptions
      .where('topic_ids && array[?]::bigint[]', [@request.topic_id])
      .where(state: [
        Subscription::State.l[:active],
        Subscription::State.l[:unverified]
      ])
  end
end
