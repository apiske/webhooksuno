# frozen_string_literal: true

class ApiKeyAcl
  def initialize
  end

  def self.create_from(acl)
    new.tap do |x|
      x.load_from(acl)
    end
  end

  def load_from(acl)
    @scopes = acl.fetch('scopes', [])
    @publish_allowed_tags = acl.dig('publish', 'allowed_tags')
    @publish_allowed_topics = acl.dig('publish', 'allowed_topics')
  end

  def has_access?(scope_name)
    @scopes.include?(scope_name) || @scopes.include?('admin')
  end

  def can_publish_tag?(topic)
    array_allowed_to?(@publish_allowed_tags, topic)
  end

  def can_publish_topic?(topic)
    array_allowed_to?(@publish_allowed_topics, topic)
  end

  private

  def array_allowed_to?(ary, entry)
    ary.present? && (ary == 'any' || ary.include?(entry))
  end
end
