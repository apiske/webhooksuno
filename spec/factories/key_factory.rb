FactoryBot.define do
  factory :key do
    is_public
    workspace
    kind { Key::Kind.l[:hmac_sha256] }
    content { SecureRandom.bytes(64) } 
  end
end
