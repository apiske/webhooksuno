# frozen_string_literal: true
class Workspace < ApplicationRecord
  include HasPublicId

  CAPABILITIES = {
    sender: 1,
    receiver: 2,
  }.freeze

  REVERSE_CAPABILITIES = CAPABILITIES.map do |k, v|
    [v, k]
  end.to_h.freeze

  has_many :topics
  has_many :webhook_definitions
  has_many :routers
  has_many :tags
  has_many :keys
  has_many :receiver_bindings
  has_many :subscriptions
  has_many :api_keys

  def has_capability?(name)
    cap_id = CAPABILITIES.fetch(name)
    capabilities.include?(cap_id)
  end

  def set_capability(name, active)
    cap_id = CAPABILITIES.fetch(name)

    if active
      self.capabilities = (capabilities + [cap_id]).uniq
    else
      self.capabilities = capabilities - [cap_id]
    end
  end
end
