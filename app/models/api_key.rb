# frozen_string_literal: true

class ApiKey < ApplicationRecord
  include HasPublicId

  attr_reader :key

  belongs_to :workspace
  belongs_to :user, optional: true

  Kind = Spyderweb::Bimap.create(
    :user_issued => 1,
    :automatic   => 2,
  ).freeze

  # State = Spyderweb::Bimap.create(
  #   :enabled  => 1,
  #   :disabled => 2,
  #   :deleted  => 3,
  # ).freeze

  def generate_secret!
    self.key_id = SecureRandom.alphanumeric(32)
    self.key_salt = SecureRandom.bytes(24)

    secret_data = SecureRandom.bytes(32)

    d = OpenSSL::Digest::SHA512.new
    d << api_key.key_salt
    d << secret_data

    self.key_secret = d.digest

    @key = [
      self.key_id,
      Base64.urlsafe_encode64(secret_data, padding: false)
    ].join
  end
end
