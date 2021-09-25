# frozen_string_literal: true

class KeySerializer < BaseSerializer
  KEY_KINDS = {
    1 => "md5",
    2 => "sha1",
    3 => "sha256",
    4 => "sha384",
    5 => "sha512",
    6 => "private_rsa",
    7 => "private_dsa"
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
