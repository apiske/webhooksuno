
module Wh::StatTracker
  Metrics = {
    publish: {
      descr: "Amount of calls to publish a webhook. Usually one per call to /v1/publish endpoint",
      workspace_scope: true,
      global_scope: true,
      type: :counter,
    },
    request_processed: {
      descr: "Amount of processed delivery requests. Should be equal or close to 'publish'",
      workspace_scope: true,
      global_scope: true,
      type: :counter,
    },
    request_fanout: {
      descr: "Amount of delivery request fanouts",
      workspace_scope: true,
      global_scope: true,
      type: :counter,
    },
    message_created: {
      descr: "Amount of messages created",
      workspace_scope: true,
      global_scope: true,
      type: :counter,
    },
    dispatch_attempt: {
      descr: "Attempts to dispatch messages",
      workspace_scope: true,
      global_scope: true,
      type: :counter,
    },
    message_delivered: {
      descr: "Amount of messages successfuly delivered",
      workspace_scope: true,
      global_scope: true,
      type: :counter,
    },
    attempt_failed: {
      descr: "Times a delivery attempt failed",
      workspace_scope: true,
      global_scope: true,
      type: :counter,
    },
    delivery_dead: {
      descr: "Amount of messages that exhausted the amount of retries and will not be retried anymore",
      workspace_scope: true,
      global_scope: true,
      type: :counter,
    },
  }.freeze

  def self.incr(workspace_id, metric, amount=1)
    local_key_name  = "stats:w#{workspace_id}:#{metric}:c"
    global_key_name = "stats:g:#{metric}:c"

    redis_url = Comff.get_str!('app.rjob.url')
    r = Redis.new(url: redis_url)
    r.pipelined do
      r.incr(local_key_name)
      r.incr(global_key_name)
    end
  end
end
