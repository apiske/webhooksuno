# frozen_string_literal: true

class PublishWorker < ::Rjob::Worker
  PHASE_MAPPING = {
    'initial' => WebhookDelivery::InitialService,
    'fanout' => WebhookDelivery::FanoutService,
    'sub' => WebhookDelivery::SubService,
    'dispatch' => WebhookDelivery::DispatchService,
  }.freeze

  def perform(phase_name, *svc_args)
    svc_klass = PHASE_MAPPING.fetch(phase_name)
    svc = svc_klass.new(*svc_args)

    svc.run
  end

  def self.retry_options
    {
      retry: false
    }
  end
end
