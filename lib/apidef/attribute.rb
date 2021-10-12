# frozen_string_literal: true

class Apidef::Attribute
  attr_reader :name
  attr_reader :type
  attr_reader :allowed_in
  attr_reader :required_in

  def initialize(api, name)
    @api = api
    @name = name
  end

  def load_definition(defn)
    @type = instantiate_type(defn)

    @allowed_in = defn["allowed_in"] || {}
    @required_in = defn["required_in"] || {}
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

end
