# frozen_string_literal: true

class WebhookDefinitionSerializer < BaseSerializer
  def model_name
    "webhook_definition"
  end

  def model_class
    WebhookDefinition
  end

  def fields
    [
      :name,
      :description,
      :retry_wait_factor,
      :retry_max_retries
    ]
  end
end
