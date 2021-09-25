# frozen_string_literal: true

class PublishService
  attr_reader :delivery_request

  def initialize(options)
    @workspace = options.fetch(:workspace)
    @message = options.fetch(:message)
    @extra_fields = options.fetch(:extra_fields)
    @topic = options.fetch(:topic)
    @include_tag_ids = options.fetch(:include_tag_ids)
    @exclude_tag_ids = options.fetch(:exclude_tag_ids)
  end

  def run
    @delivery_request = build_delivery_request
    delivery_request.save!

    Rjob.enqueue(PublishWorker, :initial, delivery_request.id)

    Wh::StatTracker.incr(@workspace.id, :publish)
  end

  private

  def build_delivery_request
    DeliveryRequest.new.tap do |req|
      req.workspace = @workspace

      req.payload = @message
      req.payload_datatype = DeliveryRequest::Datatype.l[:json]
      req.extra_fields = @extra_fields

      req.topic = @topic
      req.topic_name = @topic.name

      req.include_tag_ids = @include_tag_ids
      req.exclude_tag_ids = @exclude_tag_ids

      req.state = DeliveryRequest::State.l[:enqueued]
    end
  end
end
