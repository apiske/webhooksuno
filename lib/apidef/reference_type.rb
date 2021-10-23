# frozen_string_literal: true

class Apidef::ReferenceType < Apidef::BaseType
  def initialize(context, attr_defn)
    super(context)

    @reference_type = attr_defn.fetch("reference_type").constantize
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

  def raw_to_final_value(attr, raw_value, processor)
    ref_obj = processor.ref_solver.map_to_id(@reference_type, attr, raw_value)

    return [ref_obj.id, nil] if ref_obj

    safe_ref = raw_value.gsub('%', '%%')
    a, b = if raw_value[0] == '@'
      ["the ID #{safe_ref[1..-1]}", "ID"]
    else
      ["the name '#{safe_ref}'", "name"]
    end

    [
      nil,
      ["%s includes #{a}, but a #{@reference_type.name.downcase} with that #{b} does not exist"]
    ]
  end

  def validate_input_value(operation, attr_name, value)
    errors = []
    self.class.validate_reference_value(value, errors)

    errors
  end
end
