
class ReceiverBinding < ApplicationRecord
  # States
  # 1 - enabled
  # 2 - disabled

  State = Spyderweb::Bimap.create(
    :enabled => 1,
    :disabled => 2,
  ).freeze

  STATE_ENABLED = 1
  STATE_DISABLED = 2

  belongs_to :workspace
  belongs_to :router
  belongs_to :binding_request

  def enabled?
    state == STATE_ENABLED
  end

  def disabled?
    state == STATE_DISABLED
  end
end
