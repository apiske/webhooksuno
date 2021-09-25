# frozen_string_literal: true

class ApiV1::KeysController < ApiController
  KEY_KINDS = {
    "md5" => 1,
    "sha1" => 2,
    "sha256" => 3,
    "sha384" => 4,
    "sha512" => 5,
    "private_rsa" => 6,
    "private_dsa" => 7
  }.freeze

  class KeyContract < Wh::Contracts
    schema do
      optional(:name).value(:string)
      optional(:kind).value(:string)
      optional(:content).value(:string)
    end

    rule(:name).validate(:entity_name)
    rule(:kind) do
      next if value.nil?

      if !KEY_KINDS.key?(value)
        all_keys = KEY_KINDS.keys.join(", ")
        key.failure("must be one of (#{all_keys})")
      end
    end
  end

  before_action :fetch_key, only: [:show, :update]

  def index
    render_collection(@workspace.keys.order(name: :asc).all)
  end

  def show
    render_single(@key)
  end

  def create
    attributes = KeyContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    key = Key.new
    set_key_attributes(key, attributes)
    key.workspace = @workspace
    key.save!

    render status: :created, json: {
      data: {
        id: key.public_uuid
      }
    }
  end

  def update
    attributes = KeyContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    set_key_attributes(@key, attributes)
    @key.save!

    head 204
  end

  private

  def fetch_key
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @key = @workspace.keys.find_by!(public_id: uuid)
  end

  def set_key_attributes(key, data)
    if data.key?(:name)
      key.name = data[:name]
    end

    if data.key?(:content)
      key.content = Base64.strict_decode64(data[:content])
    end

    if data.key?(:kind)
      key.kind = KEY_KINDS.fetch(data[:kind])
    end
  end
end
