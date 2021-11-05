# frozen_string_literal: true

class ApiV1::KeysController < ApiController
  before_action :fetch_key, only: [:show, :update]
  before_action :process_input, only: [:update, :create]

  KEY_SIZES = {
    hmac_sha1: 64,
    hmac_sha256: 64,
    hmac_sha512: 128
  }.freeze

  def index
    render_collection(@workspace.keys.order(name: :asc).all)
  end

  def show
    render_single(@key)
  end

  def validate_key_content_size!
    return false unless @key.content_changed? || @key.kind_changed?

    key_kind_name = Key::Kind.r[@key.kind]
    expected_size = KEY_SIZES.fetch(key_kind_name)

    if @key.content.length != expected_size
      @processor.add_error_fmt(@processor.api_definition.attrs['content'], nil,
        "Expected a content length of exactly #{expected_size} bytes." +
        " The key content length does not match the expected length of the key specified in the kind attribute." +
        " If the key kind is hmac_sha1 or hmac_sha256, the content length must be exactly 64 bytes." +
        " For hmac_sha512, the content length must be 128 bytes"
      )
    end

    fail_on_invalid_processor!(@processor)
  end

  def create
    @key = Key.new
    @key.attributes = @processor.values_for_model
    @key.workspace = @workspace

    return if validate_key_content_size!

    return unless with_common_record_checks do
      @key.save!
    end

    render_single(@key, :created)
  end

  def update
    @key.attributes = @processor.values_for_model

    return if validate_key_content_size!

    return unless with_common_record_checks do
      @key.save!
    end

    render_single(@key)
  end

  private

  def fetch_key
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @key = @workspace.keys.find_by!(public_id: uuid)
  end

  def processor_entity_name
    :key
  end
end
