# frozen_string_literal: true

class Wh::Contracts < Dry::Validation::Contract
  register_macro(:entity_name) do
    next if value.nil?

    unless (1..200).include?(value.length)
      key.failure("length must be between 1 and 200 characters")
    end

    if value.include?("@")
      key.failure('can not contain the "@" character')
    end
  end

  register_macro(:uuid) do
    next if value.nil?

    unless value =~ /^@\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/
      key.failure("is not a valid prefixed UUID")
    end
  end

  register_macro(:uuid_or_names) do
    next if value.nil?

    value.each do |v|
      unless v =~ /^@\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/ || v =~ /^[^@]{1,200}$/
        key.failure("must contain only prefixed UUIDs or names")
        break
      end
    end
  end

  register_macro(:custom_json) do
    next if value.nil?

    # TODO: Find a better way to calculate length here
    if MultiJson.dump(value).length >= (64 * 1024)
      key.failure("must not be larger than 64KiB when JSON serialized")
    end
  end

  register_macro(:uuid_or_name) do
    next if value.nil?

    unless value =~ /^@\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/
      unless value =~ /^[^@]{1,200}$/
        key.failure("is not a valid prefixed UUID or name")
      end
    end
  end
end
