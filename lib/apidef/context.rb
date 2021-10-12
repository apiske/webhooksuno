# frozen_string_literal: true

class Apidef::Context
  attr_reader :types
  attr_accessor :ref_solver

  BASE_TYPES = [
    Apidef::StringType,
    Apidef::IntegerType,
    Apidef::EnumType,
    Apidef::NameType,
    Apidef::ReferenceType,
    Apidef::ReferenceArrayType,
    Apidef::BytesType,
  ].freeze

  def initialize
    @api_definitions = {}
    @types = Hash[BASE_TYPES.map do |klass|
      [klass.type_name, klass]
    end]
  end

  def get_api_definition(api_name)
    @api_definitions.fetch(api_name)
  end

  def load_api_definitions(file_paths)
    file_paths.each(&method(:load_api_definition))
  end

  def load_api_definition(file_path)
    api_definition = YAML.safe_load(File.read(file_path))
    api_name = File.basename(file_path).split('.')[0...-1].join

    add_api_definition(api_name, api_definition)
  end

  def create_type(name, attr_defn)
    klass = @types.fetch(name)
    klass.new(attr_defn, attr_defn)
  end

  private

  def add_api_definition(name, definition)
    @api_definitions[name] = Apidef::ApiDefinition.new(
      self,
      name,
      attributes: definition["attributes"])
  end
end
