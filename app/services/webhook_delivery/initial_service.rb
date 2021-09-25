# frozen_string_literal: true

class WebhookDelivery::InitialService
  attr_reader :request

  def initialize(request_id)
    @request = DeliveryRequest.find(request_id)
  end

  def run
    receivers = fetch_matching_receivers
    receivers.each do |recv|
      Rjob.enqueue(PublishWorker, :fanout, @request.id, recv.id)
    end

    @request.update(
      state: DeliveryRequest::State.l[:processed]
    )

    Wh::StatTracker.incr(@workspace.id, :request_processed)
  end

  private

  def fetch_matching_receivers
    query = ReceiverBinding
      .joins(:router)
      .where(receiver_bindings: {
        deleted_at: nil,
        state: ReceiverBinding::State.l[:enabled],
      })
      .where(routers: { workspace_id: @request.workspace_id })

    if @request.include_tag_ids.present?
      query = query.where('routers.tag_ids && array[?]::bigint[]',
        @request.include_tag_ids)
    end

    if @request.exclude_tag_ids.present?
      query = query.where.not('routers.tag_ids && array[?]::bigint[]',
        @request.exclude_tag_ids)
    end

    query = query.where('routers.allowed_topic_ids && array[?]::bigint[]',
      [@request.topic_id])

    query
  end
end
