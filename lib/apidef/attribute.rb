# frozen_string_literal: true

class Apidef::Attribute
  attr_reader :name
  attr_reader :type
  attr_reader :allowed_in
  attr_reader :required_in
  attr_reader :model_attr_name

  def initialize(api, name)
    @api = api
    @name = name
  end

  def load_final_input?
    @process_final_input
  end

  def load_definition(defn)
    @type = instantiate_type(defn)

    @allowed_in = defn["allowed_in"] || {}
    @required_in = defn["required_in"] || {}

    @process_final_input = defn.fetch("final_input_processing", true)

    @model_attr_name = if defn.key?("model_attr_name")
      defn["model_attr_name"]
    else
      guess_attribute_name
    end.to_sym
  end

  def presence_required?(operation)
    @required_in.include?(operation)
  end

  def presence_allowed?(operation)
    @allowed_in.include?(operation)
  end

  private

  def instantiate_type(defn)
    type_name = defn["type"]
    @api.context.create_type(type_name, defn)
  end

  def guess_attribute_name
    if type.is_a?(Apidef::ReferenceArrayType)
      "#{name.singularize}_ids"
    elsif type.is_a?(Apidef::ReferenceType)
      "#{name.singularize}_id"
    else
      name
    end
  end
end
