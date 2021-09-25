# frozen_string_literal: true

class Topic < ApplicationRecord
  include HasPublicId

  belongs_to :workspace
  belongs_to :definition, class_name: "WebhookDefinition"
end
