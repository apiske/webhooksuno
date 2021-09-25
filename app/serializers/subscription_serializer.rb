# frozen_string_literal: true

class SubscriptionSerializer < BaseSerializer
  def model_name
    "subscription"
  end

  def model_class
    Subscription
  end

  def fields
    [
      :name,
      :destination_url,
      :state,
      :destination_type,
      :key,
      :binding
    ]
  end

  def relationships
    [
      :topics
    ]
  end

  def serialize_topics(obj)
    return [] unless obj.topic_ids.present?

    # TODO: fix security issue. Limit usage to correct workspace
    Topic
      .where(id: obj.topic_ids)
      .select(:name, :public_id)
  end

  def serialize_binding(obj)
    obj.receiver_binding.binding_request.public_uuid
  end

  def serialize_key(obj)
    obj.key.name
  end

  def serialize_state(obj)
    Subscription::State[obj.state]
  end

  def serialize_destination_type(obj)
    Subscription::DestinationType[obj.destination_type]
  end
end
