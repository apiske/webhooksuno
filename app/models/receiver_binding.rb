
class ReceiverBinding < ApplicationRecord
  include HasPublicId

  # States
  # 1 - enabled
  # 2 - disabled

  STATE_ENABLED = 1
  STATE_DISABLED = 2

  State = Spyderweb::Bimap.create(
    :enabled => STATE_ENABLED,
    :disabled => STATE_DISABLED,
  ).freeze

  belongs_to :workspace
  belongs_to :router

  def enabled?
    state == STATE_ENABLED
  end

  def disabled?
    state == STATE_DISABLED
  end
end
