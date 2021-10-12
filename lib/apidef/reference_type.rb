# frozen_string_literal: true

class Apidef::ReferenceType < Apidef::BaseType
  def initialize(context, attr_defn)
    super(context)

    @reference_type = attr_defn.fetch("reference_type")
  end

  def self.type_name
    "reference"
  end

  def self.validate_reference_value(value, errors)
    if !value.is_a?(String) || value.empty?
      errors << "%s must be a non empty string"
      return false
    else
      if value[0] != '@' && !(value =~ /\A[^@]{1,200}\z/)
        errors << "%s must be either an ID prefixed with '@' or a valid name"
        return false
      end
    end

    true
  end

  def validate_input_value(operation, attr_name, value)
    errors = []
    self.class.validate_reference_value(value, errors)

    errors
  end
end
