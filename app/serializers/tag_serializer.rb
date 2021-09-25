# frozen_string_literal: true

class TagSerializer < BaseSerializer
  def model_name
    "tag"
  end

  def model_class
    Tag
  end

  def fields
    [
      :name
    ]
  end
end
