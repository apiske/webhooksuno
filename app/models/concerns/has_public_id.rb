require 'active_support/concern'

module HasPublicId
  extend ActiveSupport::Concern

  included do
    before_create :generate_public_id!
  end

  def generate_public_id!
    raise "public_id is already set!" unless public_id.nil?

    self.public_uuid = SecureRandom.uuid
  end
end
