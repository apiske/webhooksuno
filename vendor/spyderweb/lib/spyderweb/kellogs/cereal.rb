# frozen_string_literal: true

class Spyderweb::Kellogs::Cereal
  MSGPACK_MIME = "application/vnd.msgpack"
  JSON_MIME = "application/json"

  CerealizationError = Class.new(StandardError)
  CerealizationClientError = Class.new(CerealizationError)
  CerealizationServerError = Class.new(CerealizationError)

  def initialize(classes, options)
    @options = options

    @classes = Hash[classes.map do |klass|
      [klass.model_class, klass]
    end]

    setup_field_filters(classes)
  end

  def render_model(m)
    klass = @classes.fetch(m.class)
    data = serialize_single_with_class(m, klass)
    render_data(data)
  end

  def render_collection(c)
    data = c.map do |obj|
      klass = @classes.fetch(obj.class)
      serialize_single_with_class(obj, klass)
    end
    render_data(data)
  end

  private

  def serialize_single_with_class(m, klass)
    only_fields = @field_filters.dig(klass.model_class, :only)

    all_fields = klass.fields.map { |r| [r, false] }
    if klass.respond_to?(:relationships)
      all_fields += klass.relationships.map { |r| [r, true] }
    end

    result = all_fields.map do |field_name, is_relationship|
      field_name_str = field_name.to_s
      next if only_fields && !only_fields.include?(field_name_str)

      serialized_value = if klass.respond_to?("serialize_#{field_name}")
        klass.public_send("serialize_#{field_name}", m)
      else
        m.public_send(field_name)
      end

      if is_relationship
        serialized_value = if serialized_value.is_a?(Array) ||
          (defined?(ActiveRecord::Relation) && serialized_value.is_a?(ActiveRecord::Relation))
          serialized_value.map do |value|
            extract_relationship_attributes(field_name, value)
          end
        else
          extract_relationship_attributes(field_name, serialized_value)
        end
      end

      [field_name, serialized_value]
    end

    { id: m.public_uuid }.merge(Hash[result])
  end

  private

  def extract_relationship_attributes(field_name, value)
    rel_fmt = @options[:rel_fmt] || 'name'
    case rel_fmt
    when 'id'
      value.public_uuid
    when 'name'
      value.name
    when 'both'
      {
        id: value.public_uuid,
        name: value.name,
      }
    else
      raise CerealizationClientError.new("'#{rel_fmt}' is an invalid value for rel_fmt")
    end
  end

  def render_data(content)
    case @options[:mime_type]
    when MSGPACK_MIME
      [MSGPACK_MIME, MessagePack.pack({ data: content })]
    when JSON_MIME
      [JSON_MIME, MultiJson.dump({ data: content })]
    else
      raise "Invalid mime type: #{@options[:mime_type]}"
    end
  end

  def setup_field_filters(classes)
    @field_filters = {}
    return unless @options[:fields_filter]

    classes.each do |klass|
      filter_string = @options[:fields_filter][klass.model_name]
      next unless filter_string

      @field_filters[klass.model_class] = {
        only: filter_string.split(",")
      }
    end
  end
end
