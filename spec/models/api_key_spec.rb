require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  describe '#generate_secret!' do
    let(:instance) { described_class.new }

    subject { instance.key }

    before do
      instance.generate_secret!
    end

    it { is_expected.to be_a(String) }

    it 'has a valid key_id portion' do
      expect(subject[0...32]).to eq(instance.key_id)
    end

    it 'generates a valid key' do
      d = OpenSSL::Digest::SHA512.new
      d << instance.key_salt
      d << Base64.urlsafe_decode64(subject[32..])

      expect(d.digest).to eq(instance.key_secret)
    end
  end
end
