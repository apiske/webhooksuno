# frozen_string_literal: true

class WebhookDelivery::DispatchService
  attr_reader :message

  def initialize(message_id, subscription_id)
    @message = Message.find(message_id)
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
    'application/json'
  end

  # irb(main):035:0> (1..18).each {|x| puts("%02d -> %s" % [x, beauty_time(2 ** x + 3*x + 10)]) };nil
  #   01 -> 15s
  #   02 -> 20s
  #   03 -> 27s
  #   04 -> 38s
  #   05 -> 57s
  #   06 -> 1m
  #   07 -> 2m
  #   08 -> 4m
  #   09 -> 9m
  #   10 -> 17m
  #   11 -> 34m
  #   12 -> 1h
  #   13 -> 2h
  #   14 -> 4h
  #   15 -> 9h
  #   16 -> 18h
  #   17 -> 1d
  #   18 -> 3d
  def retry_dispatch
    tries = @message.delivery_tentatives_at.length
    seconds_from_now = 2 ** tries + 3 * tries + rand(0..15)

    Rjob.schedule_in(
      seconds_from_now,
      ::PublishWorker,
      :dispatch,
      @message.id,
      @subscription.id)
  end

  def max_delivery_tentatives
    # PT: #179758663
    # TODO: read delivery tentatives from WebhookDefinition
    5
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
