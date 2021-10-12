# frozen_string_literal: true

class Apidef::BytesType < Apidef::BaseType
  def self.type_name
    "bytes"
  end

  def validate_input_value(operation, attr_name, value)
    return if value.is_a?(String)

    ["%s must be a string"]
  end

  def raw_to_final_value(attr, raw_value, processor)
    begin
      return Base64.strict_decode64(raw_value)
    rescue ArgumentError => e
      if e.message == "invalid base64"
        return nil, ["%s must be a valid Base64 value"]
      end
      raise e
    end
  end
end
