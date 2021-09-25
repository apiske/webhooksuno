# frozen_string_literal: true

class Subscription < ApplicationRecord
  include HasPublicId

  DestinationType = Spyderweb::Bimap.create(
    :https     => 1,
    :grpc      => 2,
    :sns       => 3,
    :polling   => 4,
    :websocket => 5,
    :amqp      => 6,
  ).freeze

  State = Spyderweb::Bimap.create(
    :unverified => 1,
    :active     => 2,
    :disabled   => 3,
    :error      => 4,
  ).freeze

  belongs_to :workspace
  belongs_to :receiver_binding
  belongs_to :key

  def router
    receiver_binding.router
  end
end
