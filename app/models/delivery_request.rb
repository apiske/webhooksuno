# frozen_string_literal: true

class DeliveryRequest < ApplicationRecord
  include HasPublicId

  State = Spyderweb::Bimap.create(
    :scheduled  => 1,
    :enqueued   => 2,
    :processed  => 3,
  ).freeze

  Datatype = Spyderweb::Bimap.create(
    :json    => 1,
    :msgpack => 2,
    :xml     => 3,
    :binary  => 4,
  ).freeze

  belongs_to :workspace
  belongs_to :topic
end
