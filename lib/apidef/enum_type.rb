# frozen_string_literal: true

class Apidef::EnumType < Apidef::BaseType
  def initialize(context, attr_defn)
    super(context)

    unless @enum_options = attr_defn["enum_options"]
      raise "When type is 'enum', 'enum_options' must also be present"
    end
  end

  def self.type_name
    "enum"
  end

  def validate_input_value(operation, attr_name, value)
    return if @enum_options.include?(value)

    options = @enum_options.join(', ')

    ["%s must be one of: #{options}"]
  end
end
