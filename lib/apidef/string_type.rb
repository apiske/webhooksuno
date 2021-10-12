# frozen_string_literal: true

class Apidef::StringType < Apidef::BaseType
  def self.type_name
    "string"
  end

  def validate_input_value(operation, attr_name, value)
    return if value.is_a?(String)

    ["%s must be a string"]
  end
end
