# frozen_string_literal: true

class Apidef::ApiDefinition
  attr_reader :context
  attr_reader :attrs

  def initialize(context, name, attributes:)
    @context = context
    @name = name
    @attrs = {}
    attributes.each(&method(:load_attribute_definition))
  end

  private

  def load_attribute_definition(attr_name, defn)
    attr = Apidef::Attribute.new(self, attr_name)
    attr.load_definition(defn)

    @attrs[attr_name] = attr
  end
end
