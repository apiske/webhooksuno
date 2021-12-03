# frozen_string_literal: true

class ApiV1::PublisherController < ApiController
  # class RouterContract < Wh::Contracts
  #   schema do
  #     optional(:name).value(:string)
  #     optional(:tags).array(:string)
  #     optional(:allowed_topics).array(:string)
  #     optional(:custom_attributes)
  #   end
  #
  #   rule(:name).validate(:entity_name)
  #   rule(:tags).validate(:uuid_or_names)
  #   rule(:allowed_topics).validate(:uuid_or_names)
  #   rule(:custom_attributes).validate(:custom_json)
  # end
  requires_workspace_capability :sender

  def publish
    data = body_obj['data'].symbolize_keys

    message = data[:message]
    extra_fields = data[:extra_fields]
    p_topic = data[:topic]

    p_include_tags = data[:include_tags] || []
    p_exclude_tags = data[:exclude_tags] || []

    topic_query = ModelUtil.terms_query(Topic, [p_topic])
    topic = @workspace.topics.where(topic_query).first!

    include_tags_query = ModelUtil.terms_query(Tag, p_include_tags)
    include_tags = @workspace.tags.where(include_tags_query).to_a

    exclude_tags_query = ModelUtil.terms_query(Tag, p_exclude_tags)
    exclude_tags = @workspace.tags.where(exclude_tags_query).to_a

    svc = PublishService.new({
      workspace: @workspace,
      message: message,
      extra_fields: extra_fields,
      topic: topic,
      include_tag_ids: include_tags.map(&:id),
      exclude_tag_ids: exclude_tags.map(&:id)
    })

    svc.run

    render status: 200, json: MultiJson.dump({
      data: {
        delivery_request_id: svc.delivery_request.public_uuid
      }
    })
  end
end
