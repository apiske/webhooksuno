# frozen_string_literal: true

class ReceiverBindingSerializer < BaseSerializer
  def model_name
    "receiver_binding"
  end

  def model_class
    ReceiverBinding
  end

  def fields
    [
      :name,
      :router_id,
      :state
    ]
  end

  def relationships
    []
  end

  def serialize_router_id(obj)
    obj.router.public_uuid
  end

  def serialize_state(obj)
    ReceiverBinding::State[obj.state]
  end
end
