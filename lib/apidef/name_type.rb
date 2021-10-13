# frozen_string_literal: true

class Apidef::NameType < Apidef::BaseType
  def self.type_name
    "name"
  end

  def validate_input_value(operation, attr_name, value)
    errors = []

    if value.is_a?(String)
      if !(value =~ /\A[^@]{1,200}\z/)
        errors << "%s must be a string between 1 and 200 characters and must not contain the symbol '@'"
      end
    else
      errors << "%s must be a valid name, therefore also a string"
    end

    errors
  end

  def raw_to_final_value(attr, raw_value, processor)
    raw_value.downcase
  end
end
