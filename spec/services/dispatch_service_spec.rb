require 'rails_helper'

RSpec.describe WebhookDelivery::DispatchService do
  let(:sender_ws) { create(:workspace) }
  let(:recv_ws) { create(:workspace) }
  let(:message) { create(:message, receiver_workspace: recv_ws, sender_workspace: sender_ws) }
  let(:subscription) { create(:subscription, workspace: recv_ws, destination_url: 'https://webhook.site/494b2de7-90cb-4114-915c-0b32573a7522') }
  let(:sig_key) { subscription.key }

  describe '#run' do
    let(:send_time) { Time.at(rand(1.6e9..1.9e9).to_i) }
    subject(:run) do
      VCR.use_cassette(:dispatch_message_01) do
        Timecop.freeze(send_time) do
          described_class.new(message.id, subscription.id).run
        end
      end
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

    xit 'tracks amount of messages sent' do
      # TODO:
    end
  end
end
