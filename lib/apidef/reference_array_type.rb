# frozen_string_literal: true

class Apidef::ReferenceArrayType < Apidef::BaseType
  def initialize(context, attr_defn)
    super(context)

    @reference_type = attr_defn.fetch("reference_type").constantize
  end

  def self.type_name
    "reference_array"
  end

  def validate_input_value(operation, attr_name, value)
    errors = []

    if !value.is_a?(Array)
      errors << "%s must be an array"
    else
      value.each do |elem|
        break unless self.class.validate_reference_value(elem, errors)
      end
    end

    errors
  end

  def raw_to_final_value(attr, raw_value, processor)
    errors = []
    id_map = processor.ref_solver.map_to_ids(@reference_type, attr, raw_value)
    id_map.each do |ref, id|
      next if id != nil

      safe_ref = ref.gsub('%', '%%')
      a, b = if ref[0] == '@'
        ["the ID #{safe_ref[1..-1]}", "ID"]
      else
        ["the name '#{safe_ref}'", "name"]
      end

      errors << "%s includes #{a}, but a #{@reference_type.name.downcase} with that #{b} does not exist"
    end

    [id_map.values, errors]
  end

  def self.validate_reference_value(value, error)
    if !value.is_a?(String) || value.empty?
      errors << "Elements of %s must be non empty strings"
      return false
    else
      if value[0] != '@' && !(value =~ /\A[^@]{1,200}\z/)
        errors << "Elements of %s must be either IDs prefixed with '@' or valid names"
        return false
      end
    end

    true
  end
end
