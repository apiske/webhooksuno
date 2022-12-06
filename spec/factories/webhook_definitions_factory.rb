FactoryBot.define do
  factory :webhook_definition do
    is_public

    workspace
    description { FFaker::DizzleIpsum.phrase }

    retry_wait_factor { 2 }
    retry_max_retries { 7 }
  end
end
