# frozen_string_literal: true

class Apidef::IntegerType < Apidef::BaseType
  def initialize(context, attr_defn)
    super(context)

    if type_defn = attr_defn["integer_validation"]
      @gte = type_defn["gte"]
      @lte = type_defn["lte"]
    end
  end

  def self.type_name
    "integer"
  end

  def validate_input_value(operation, attr_name, value)
    invalid = !value.is_a?(Integer)
    errors = []

    errors << "%s must be an integer" if invalid

    errors << "%s must be greater or equal than #{@gte}" if invalid || (@gte && value < @gte)

    errors << "%s must be lesser or equal than #{@lte}" if invalid || (@lte && value > @lte)

    errors
  end
end
