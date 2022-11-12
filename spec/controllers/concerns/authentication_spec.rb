# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authentication do
  let(:fake_class) do
    Class.new do
      def request; end
      def render(status:, json:); end
    end.tap do |c|
      c.include Authentication
    end
  end
  let(:ctrl) { fake_class.new }
  let(:headers_mock) { { 'HTTP_AUTHORIZATION' => "Bearer #{token}" } }
  let(:request_mock) { double }

  before do
    allow(request_mock).to receive(:headers).and_return(headers_mock)
    allow(ctrl).to receive(:request).and_return(request_mock)
    allow(ctrl).to receive(:render) do |status:, json:|
      @response_status = status

      false
    end
  end

  describe '#check_login' do
    subject { ctrl.check_login }

    context 'when token is invalid' do
      let(:token) { 'foo' }

      it 'renders status 403' do
        expect(subject).to be false
        expect(@response_status).to eq(403)
      end
    end

    context 'when token is valid' do
      let(:api_key) { build(:api_key) }
      let(:token) { api_key.key }

      context 'when token exists in the DB' do
        before { api_key.save! }

        it 'is successful' do
          expect(subject).to be(true)
          expect(@response_status).to be_nil
        end
      end

      context 'when token is not in the DB' do
        it 'renders status 403' do
          expect(subject).to be false
          expect(@response_status).to eq(403)
        end
      end
    end
  end
end
