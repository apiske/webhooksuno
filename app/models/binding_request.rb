
class BindingRequest < ApplicationRecord
  include HasPublicId

  UseType = Spyderweb::Bimap.create(
    :once => 1,
    :once_per_workspace => 2,
    :unlimited => 3
  ).freeze

  belongs_to :workspace
  belongs_to :router

  has_many :receiver_bindings
end
