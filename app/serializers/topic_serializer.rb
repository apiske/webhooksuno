# frozen_string_literal: true

class TopicSerializer < BaseSerializer
  def model_name
    "topic"
  end

  def model_class
    Topic
  end

  def fields
    [
      :name,
      :public_description,
      :webhook_definition
    ]
  end

  def serialize_webhook_definition(obj)
    # TODO:
    "TODO:FIXME"
    obj.definition.name
  end
end
