# frozen_string_literal: true

class WebhookDefinition < ApplicationRecord
  include HasPublicId

  belongs_to :workspace
  has_many :topics, foreign_key: :definition_id
end
