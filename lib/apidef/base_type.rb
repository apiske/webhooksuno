# frozen_string_literal: true

class Apidef::BaseType
  def initialize(context, attr_defn=nil)
    @context = context
  end

  # def self.type_name
  #   raise NotImplementedError.new
  # end

  # operation = :create or :update
  # must return an array of errors. An error is a string
  # with %s to be replaced with the attribute name
  def validate_input_value(operation, attr_name, value)
    raise NotImplementedError.new
  end

  def raw_to_final_value(attr, raw_value, processor)
    raw_value
  end
end
