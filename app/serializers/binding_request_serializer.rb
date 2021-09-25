# frozen_string_literal: true

class BindingRequestSerializer < BaseSerializer
  USE_TYPES = {
    1 => "once",
    2 => "unlimited",
    3 => "once_per_workspace"
  }.freeze

  def model_name
    "binding_request"
  end

  def model_class
    BindingRequest
  end

  def fields
    [
      :use_type,
      :message
    ]
  end

  def relationships
    [
      :router,
      # allowed_workspace_ids # TODO:
    ]
  end

  def serialize_use_type(obj)
    USE_TYPES[obj.use_type]
  end

  def serialize_router(obj)
    obj.router
  end
end
