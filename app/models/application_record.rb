class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def public_uuid
    UuidUtil.uuid_bin_to_s(public_id)
  end

  def public_uuid=(v)
    self.public_id = UuidUtil.uuid_s_to_bin(v)
  end
end
