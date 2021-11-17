# frozen_string_literal: true

class Spyderweb::Kellogs::Cereal
  MSGPACK_MIME = "application/vnd.msgpack"
  JSON_MIME = "application/json"

  CerealizationError = Class.new(StandardError)
  CerealizationClientError = Class.new(CerealizationError)
  CerealizationServerError = Class.new(CerealizationError)
  CerealizationPageDataError = Class.new(CerealizationClientError)

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

  def render_collection_paginated(rel, page_cursor, page_size)
    if !page_cursor || page_cursor == '0' || page_cursor == 'first' || page_cursor.empty?
      page_cursor = 0
    else
      begin
        cipher = RbNaCl::AEAD::ChaCha20Poly1305IETF.new(pagination_cursor_key)
        hdata = Base64.urlsafe_decode64(page_cursor)
        nonce, enc_data = hdata[1..12], hdata[13..-1]
        data = cipher.decrypt(nonce, enc_data, '')
        page_cursor = Integer(data.unpack('L>').first)
      rescue RbNaCl::CryptoError, RbNaCl::LengthError, ArgumentError => e
        raise CerealizationPageDataError.new
      end
    end

    items = rel
      .where('id >= ?', page_cursor)
      .order(id: :asc)
      .limit(page_size + 1)
      .to_a

    last_page = (items.length <= page_size)
    next_id = unless last_page
      cipher = RbNaCl::AEAD::ChaCha20Poly1305IETF.new(pagination_cursor_key)
      nonce = RbNaCl::Random.random_bytes(12)
      enc_data = [items.pop.id].pack('L>')
      bin_cursor = "1#{nonce}" + cipher.encrypt(nonce, enc_data, '')
      Base64.urlsafe_encode64(bin_cursor, padding: false)
    end

    data = items.map do |obj|
      klass = @classes.fetch(obj.class)
      serialize_single_with_class(obj, klass)
    end

    page_data = {
      has_more: !last_page,
      size: page_size
    }

    page_data[:next] = next_id.to_s unless last_page

    [JSON_MIME, MultiJson.dump({
      data: data,
      page: page_data
    })]
  end

  def render_collection(c)
    data = c.map do |obj|
      klass = @classes.fetch(obj.class)
      serialize_single_with_class(obj, klass)
    end
    render_data(data)
  end

  private

  def pagination_cursor_key
    @options[:pagination_cursor_key]
  end

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
