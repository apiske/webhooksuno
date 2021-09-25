# frozen_string_literal: true

class Tag < ApplicationRecord
  include HasPublicId

  belongs_to :workspace
end
