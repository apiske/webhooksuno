
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot.define do
  trait :is_public do
    name { FFaker::Internet.domain_word }
  #   public_id { UuidUtil.uuid_s_to_bin(SecureRandom.uuid) }
  end
end
