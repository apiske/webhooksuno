# frozen_string_literal: true

class Apidef::EnumType < Apidef::BaseType
  def initialize(context, attr_defn)
    super(context)

    @enum_map = attr_defn["enum_map"]
    enum_options = attr_defn["enum_options"]

    if [@enum_map, enum_options].compact.length != 1
      raise "When type is 'enum', either 'enum_options' or 'enum_map' (but not both) must be present"
    end

    @enum_options = enum_options || @enum_map.keys
  end

  def self.type_name
    "enum"
  end

  def validate_input_value(operation, attr_name, value)
    return if @enum_options.include?(value)

    options = @enum_options.join(', ')

    ["%s must be one of: #{options}"]
  end

  def raw_to_final_value(attr, raw_value, processor)
    if @enum_map
      @enum_map.fetch(raw_value)
    else
      raw_value
    end
  end
end
