require 'rails_helper'

RSpec.describe WebhookDelivery::DispatchService do
  let(:sender_ws) { create(:workspace) }
  let(:recv_ws) { create(:workspace) }
  let(:message) { create(:message, receiver_workspace: recv_ws, sender_workspace: sender_ws) }
  let(:subscription) { create(:subscription, workspace: recv_ws, destination_url: 'https://webhook.site/494b2de7-90cb-4114-915c-0b32573a7522') }
  let(:sig_key) { subscription.key }
  let(:vcr_cassette) { :dispatch_message_01 }

  describe '#run' do
    let(:send_time) { Time.at(rand(1.6e9..1.9e9).to_i) }

    subject(:run) do
      VCR.use_cassette(vcr_cassette) do
        Timecop.freeze(send_time) do
          described_class.new(message.id, subscription.id).run
        end
      end
    end

    before do
      allow(Wh::StatTracker).to receive(:incr)
    end

    it 'produces a valid signature' do
      run
      message.reload

      sent_time, sent_sig = message.request_headers['Wh-Uno-Signature'].split(',', 2)

      digest = sig_key.create_digest
      hmac = OpenSSL::HMAC.new(sig_key.content, digest)
      hmac << "#{send_time.to_i.to_s}.#{message.payload}"

      expect(Integer(sent_time)).to eq(send_time.to_i)
      expect(sent_sig).to eq(hmac.hexdigest)
    end

    it 'sets request headers' do
      run
      message.reload

      expect(message.request_headers.except('Wh-Uno-Signature')).to eq({
        'User-Agent' => 'webhooks.uno/0.1a',
        'Content-Type' => 'application/json',
      })
    end

    it 'fires the webhook and updates the message with the response' do
      run
      message.reload

      expect(message.response_body).to eq('{"foo":"bar"}')
      expect(message.response_headers).to eq({
        'Server' => 'nginx',
        'Content-Length' => '13',
        'Content-Type' => 'application/json; charset=UTF-8',
        'Vary' => 'Accept-Encoding',
        'X-Request-Id' => '4259c725-143e-44e2-adfe-9adaee9d4be1',
        'X-Token-Id' => '494b2de7-90cb-4114-915c-0b32573a7522',
        'Cache-Control' => 'no-cache, private',
        'Date' => 'Tue, 29 Nov 2022 23:19:42 GMT',
      })
      expect(message.response_status_code).to eq(250)

      expect(message.delivered_at).to eq(send_time)
      expect(message.state).to eq(Message::State.l[:delivered])
      expect(message.delivery_tentatives_at).to eq([send_time])
    end

    it 'tracks amount of messages sent' do
      run

      expect(Wh::StatTracker).to have_received(:incr)
        .with(sender_ws.id, :message_delivered).once

      expect(Wh::StatTracker).to have_received(:incr)
        .with(sender_ws.id, :dispatch_attempt).once
    end

    context 'when there is a socket error' do
      before do
        allow(Excon).to receive(:post).and_raise(Excon::Error::Socket.new(OpenStruct.new(message: 'the-error-msg')))
      end

      it 'does not deliver and sets failure attributes' do
        run
        message.reload

        expect(message.failure_message).to eq('Excon::Error::Socket->the-error-msg (OpenStruct)')
        expect(message.failure_code).to eq(Message::FailureCode.l[:generic_socket_error])
        expect(message.delivery_tentatives_at).to eq([send_time])
        expect(message.delivered_at).to be_nil
        expect(message.state).to eq(Message::State.l[:enqueued])

        expect(Wh::StatTracker).to have_received(:incr)
          .with(sender_ws.id, :attempt_failed).once
      end
    end

    context 'when there is a generic error' do
      before do
        allow(Excon).to receive(:post).and_raise(StandardError, 'wow-such-standard')
      end

      it 'does not deliver and sets failure attributes' do
        run
        message.reload

        expect(message.failure_message).to eq('StandardError->wow-such-standard')
        expect(message.failure_code).to eq(Message::FailureCode.l[:other])
        expect(message.delivery_tentatives_at).to eq([send_time])
        expect(message.delivered_at).to be_nil
        expect(message.state).to eq(Message::State.l[:enqueued])

        expect(Wh::StatTracker).to have_received(:incr)
          .with(sender_ws.id, :attempt_failed).once
      end
    end

    describe 'retrying send' do
      before do
        allow(Excon).to receive(:post).and_raise(StandardError, 'anything-really')
        allow(Rjob).to receive(:schedule_in)
        allow(Kernel).to receive(:rand).and_return(3)
      end

      it 'reschedules the job for later' do
        run
        message.reload

        expect(message.delivery_tentatives_at).to eq([send_time])
        expect(Rjob).to have_received(:schedule_in)
          .with(
            (2...62),
            ::PublishWorker,
            :dispatch,
            message.id,
            subscription.id
          ).once
      end

      context 'when over retry limit' do
        before do
          message.update_columns(delivery_tentatives_at: [
            send_time,
            send_time + 1.hour,
            send_time + 2.hours,
            send_time + 3.hours,
            send_time + 4.hours,
            send_time + 5.hours,
            send_time + 6.hours
          ])
        end

        it 'sets the message as failed' do
          run
          message.reload

          expect(Rjob).not_to have_received(:schedule_in)
          expect(message.delivered_at).to be_nil
          expect(message.state).to eq(Message::State.l[:failed])

          expect(Wh::StatTracker).not_to have_received(:incr)
            .with(sender_ws.id, :attempt_failed)
          expect(Wh::StatTracker).to have_received(:incr)
            .with(sender_ws.id, :delivery_dead).once
        end
      end
    end

    context 'when response is not 2xx' do
      let(:vcr_cassette) { :dispatch_message_02_non_2xx }

      it 'does not set the message as delivered' do
        run
        message.reload

        expect(message.delivered_at).to be_nil
        expect(message.state).to eq(Message::State.l[:enqueued])
        expect(message.delivery_tentatives_at).to eq([send_time])
      end

      it 'updates message response attributes' do
        run
        message.reload

        expect(message.response_body).to eq('foo')
        expect(message.response_headers).to eq({
          'Server' => 'nginx',
          'Content-Length' => '3',
          'Content-Type' => 'text/plain',
          'Vary' => 'Accept-Encoding',
          'X-Request-Id' => '4259c725-143e-44e2-adfe-9adaee9d4be1',
          'X-Token-Id' => '494b2de7-90cb-4114-915c-0b32573a7522',
          'Cache-Control' => 'no-cache, private',
          'Date' => 'Tue, 29 Nov 2022 23:19:42 GMT',
        })
        expect(message.response_status_code).to eq(404)
      end

      it 'does not track' do
        run

        expect(Wh::StatTracker).not_to have_received(:incr)
          .with(sender_ws.id, :message_delivered)
      end
    end
  end
end
