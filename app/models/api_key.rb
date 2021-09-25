# frozen_string_literal: true

class ApiKey < ApplicationRecord
  include HasPublicId

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
    self.secret = SecureRandom.bytes(128)
  end
end
