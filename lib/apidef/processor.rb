# frozen_string_literal: true

class Apidef::Processor
  attr_reader :context
  attr_reader :errors
  # attr_reader :warnings
  attr_reader :operation
  attr_reader :ref_solver

  ERROR_MESSAGES = {
    attr_is_required: "%s is required",
    attr_not_allowed: "%s must not be present",
  }

  def initialize(operation, context, api_name, ref_solver)
    @context = context
    @operation = operation.to_s
    @api_name = api_name.to_s
    @ref_solver = ref_solver

    @errors = []
    # @warnings = []

    @not_present = Object.new
    @raw_values = {}
    @values = {}
  end

  def valid?
    @errors.empty?
  end

  def process_input(input_data)
    @input_data = input_data

    _process_input

    valid?
  end

  # def warnings?
  # end

  private

  attr_reader :not_present

  def _process_input
    attrs = api_definition.attrs

    check_unknown_attributes

    attrs.values.each do |attr|
      load_raw_input_values(attr)
    end

    return unless @errors.empty?

    @raw_values.each do |attr_name, raw_value|
      attr = attrs[attr_name]
      load_final_input_values(attr, raw_value)
    end
  end

  private

  def api_definition
    @api_definition ||= @context.get_api_definition(@api_name)
  end

  def check_unknown_attributes
    known_attrs = Set.new(api_definition.attrs.keys.map(&:to_s))
    unknown_attrs = Set.new(@input_data.keys.map(&:to_s)) - known_attrs

    unknown_attrs.each do |attr_name|
      errors << [
        attr_name,
        "The attribute '#{attr_name}' does not exist. It cannot be present in the input payload"
      ]
    end
  end

  def load_final_input_values(attr, raw_value)
    final_value, err = attr.type.raw_to_final_value(attr, raw_value, self)

    if !err || err.empty?
      @values[attr.name] = final_value
    else
      err.each do |err_fmt|
        add_error_fmt(attr, raw_value, err_fmt)
      end
    end
  end

  def load_raw_input_values(attr)
    value = @input_data.fetch(attr.name, not_present)

    if value == not_present
      add_error(attr, value, :attr_is_required) if attr.presence_required?(@operation)
    else
      if attr.presence_allowed?(@operation)
        if validate_attribute_input_value(attr, value)
          @raw_values[attr.name] = value
        end
      else
        add_error(attr, value, :attr_not_allowed)
      end
    end
  end

  def validate_attribute_input_value(attr, value)
    type_errors = attr.type.validate_input_value(@operation, attr.name, value)
    return true if type_errors == nil || type_errors.empty?

    type_errors.each do |err|
      add_error_fmt(attr, value, err)
    end

    false
  end

  def add_error_fmt(attr, value, error_fmt)
    error_msg = error_fmt % [attr.name]
    @errors << [attr, error_msg]
  end

  def add_error(attr, value, error_name)
    msg_fmt = ERROR_MESSAGES.fetch(error_name)
    add_error_fmt(attr, value, msg_fmt)
  end
end
