
class Key < ApplicationRecord
  include HasPublicId

  belongs_to :workspace
  has_many :subscriptions

  Kind = Spyderweb::Bimap.create(
    :hmac_sha1     => 1, # HMAC-SHA-1, key size of 64 bytes, output of 20 bytes
    :hmac_sha256   => 2, # HMAC-SHA2-256, key size of 64 bytes, output of 32 bytes
    :hmac_sha512   => 3  # HMAC-SHA2-512, key size of 128 bytes, output of 64 bytes
  ).freeze

  def has_digest_capability?
    (1..3).include?(kind)
  end

  def create_digest
    algorithm_name = Kind.r[kind].to_s[5..-1]
    OpenSSL::Digest.new(algorithm_name)
  end
end
