
class Key < ApplicationRecord
  include HasPublicId

  belongs_to :workspace
  has_many :subscriptions

  Kind = Spyderweb::Bimap.create(
    :md5         => 1,
    :sha1        => 2,
    :sha256      => 3,
    :sha384      => 4,
    :sha512      => 5,
    :private_rsa => 6,
    :private_dsa => 7
  ).freeze

  def has_digest_capability?
    (1..5).include?(kind)
  end

  def create_digest
    algorithm_name = Kind.r[kind].to_s
    OpenSSL::Digest.new(algorithm_name)
  end
end
