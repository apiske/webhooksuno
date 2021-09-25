# frozen_string_literal: true

class RouterSerializer < BaseSerializer
  def model_name
    "router"
  end

  def model_class
    Router
  end

  def fields
    [
      :name,
      :custom_attributes,
    ]
  end

  def relationships
    [
      :allowed_topics,
      :tags
    ]
  end

  def serialize_allowed_topics(obj)
    return [] unless obj.allowed_topic_ids.present?
    obj.workspace.topics
      .where(id: obj.allowed_topic_ids)
      .select(:name, :public_id)
  end
end
