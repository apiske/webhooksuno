# frozen_string_literal: true

class Router < ApplicationRecord
  include HasPublicId

  belongs_to :workspace
  has_many :receiver_bindings
  has_many :binding_requests
end
