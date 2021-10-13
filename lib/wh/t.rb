# frozen_string_literal: true

module Wh::T
  include Dry.Types()

  Name = String.constrained(format: /\A[^@]{1,200}\z/)

  UnprefixedUuid = String.constrained(format: /^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/)

  Uuid = String.constrained(format: /^@\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/)

  NameOrUuid = Name | Uuid
end
