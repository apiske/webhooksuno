# frozen_string_literal: true

class KeySerializer < BaseSerializer
  KEY_KINDS = {
    Key::Kind.l[:hmac_sha1] => "hmac_sha1",
    Key::Kind.l[:hmac_sha256] => "hmac_sha256",
    Key::Kind.l[:hmac_sha512] => "hmac_sha512",
  }.freeze

  def model_name
    "key"
  end

  def model_class
    Key
  end

  def fields
    [
      :name,
      :kind
    ]
  end

  def serialize_kind(obj)
    KEY_KINDS[obj.kind]
  end
end
