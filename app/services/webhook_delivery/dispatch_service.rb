# frozen_string_literal: true

class WebhookDelivery::DispatchService
  attr_reader :message

  def initialize(message_id, subscription_id)
    @message = Message
      .eager_load(:definition)
      .find(message_id)
    @webhook_definition = @message.definition
    @subscription = Subscription
      .eager_load(:key)
      .find(subscription_id)
    @key = @subscription.key
    @time_now = Time.now.utc
  end

  def run
    @sending_time = Time.now.utc
    signature = make_signature

    @message.request_headers = {
      'Wh-Uno-Signature' => signature,
      'User-Agent' => 'webhooks.uno/0.1a',
      'Content-Type' => content_type
    }

    dispatch_message

    @message.save

    Wh::StatTracker.incr(@message.sender_workspace_id, :dispatch_attempt)
  end

  private

  def content_type
    "application/json"
  end

  def wait_factor
    @webhook_definition.retry_wait_factor
  end

  def retry_dispatch
    retries = @message.delivery_tentatives_at.length
    seconds_from_now = ((wait_factor/100.0)*30.0 + 2.0**(retries*(wait_factor / 100.0)) + rand((0...60))).ceil

    Rjob.schedule_in(
      seconds_from_now,
      ::PublishWorker,
      :dispatch,
      @message.id,
      @subscription.id)
  end

  def max_delivery_tentatives
    @webhook_definition.retry_max_retries + 1
  end

  def dispatch_message
    response = begin
      Excon.post(
        @subscription.destination_url,
        headers: @message.request_headers,
        body: @message.payload
      )
    rescue => e
      e
    end

    @message.delivery_tentatives_at = [] unless @message.delivery_tentatives_at

    @message.delivery_tentatives_at << @time_now

    if response.is_a?(StandardError)
      e = response
      @message.failure_message = "#{e.class}->#{e.message}"

      if e.class <= Excon::Error::Socket
        # If it's some sort of socket error
        if e.socket_error.class <= Resolv::ResolvError && e.message =~ %r(^no address for)
          @message.failure_code = Message::FailureCode.l[:name_not_resolved]
          @message.failure_message = e.message
        else
          @message.failure_code = Message::FailureCode.l[:generic_socket_error]
        end
      else
        @message.failure_code = Message::FailureCode.l[:other]
      end

      if @message.delivery_tentatives_at.length < max_delivery_tentatives
        @message.save

        retry_dispatch

        Wh::StatTracker.incr(@message.sender_workspace_id, :attempt_failed)
      else
        @message.state = Message::State.l[:failed]
        @message.save

        Wh::StatTracker.incr(@message.sender_workspace_id, :delivery_dead)
      end
    else
      @message.response_body = response.body&.b
      @message.response_headers = response.headers
      @message.response_status_code = response.status

      delivered = (200..299).include?(response.status)
      if delivered
        @message.delivered_at = @time_now
        @message.state = Message::State.l[:delivered]
      end

      @message.save

      Wh::StatTracker.incr(@message.sender_workspace_id, :message_delivered) if delivered
    end
  end

  def make_signature
    digest = calculate_signature_digest
    "#{@sending_time.to_i},#{digest}"
  end

  def calculate_signature_digest
    digest = @key.create_digest
    hmac = OpenSSL::HMAC.new(@key.content, digest)
    hmac << @sending_time.to_i.to_s
    hmac << '.'
    hmac << @message.payload

    hmac.hexdigest
  end
end
