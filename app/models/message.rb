# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :sender_workspace, class_name: 'Workspace'
  belongs_to :receiver_workspace, class_name: 'Workspace'
  belongs_to :delivery_request
  belongs_to :definition, class_name: "WebhookDefinition"

  before_create :generate_id!

  State = Spyderweb::Bimap.create(
    :enqueued   => 1,
    :delivered  => 2,
    :failed     => 3,
  ).freeze

  FailureCode = Spyderweb::Bimap.create(
    :name_not_resolved     => 1,
    :generic_socket_error  => 2,

    :other                 => 100
  ).freeze

  def generate_id!
    raise 'message ID is already set!' unless id.nil?

    self.id = SecureRandom.bytes(128)
  end

  def public_id
    id.unpack('H*').first
  end
end
