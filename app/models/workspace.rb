# frozen_string_literal: true
class Workspace < ApplicationRecord
  include HasPublicId

  has_many :topics
  has_many :webhook_definitions
  has_many :routers
  has_many :tags
  has_many :keys
  has_many :receiver_bindings
  has_many :subscriptions
  has_many :api_keys
end
