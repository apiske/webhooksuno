# frozen_string_literal: true

module ObjStatman
  class Context
    attr_reader :redis_conn
    attr_reader :prefix

    def initialize(redis_url, prefix)
      @prefix = prefix
      @redis_conn = Redis.new(url: redis_url)
    end

    def counter_incr(namespace, key, incr_by=1)
      redis_key = "#{redis_base_key(namespace, key)}:v"
      @redis_conn.incrby(redis_key, incr_by)
    end

    def counter_set(namespace, key, value)
      redis_key = "#{redis_base_key(namespace, key)}:v"
      @redis_conn.set(redis_key, value)
    end

    def list_set(namespace, key, values)
      redis_key = "#{redis_base_key(namespace, key)}:v"
      @redis_conn.pipelined do |pr|
        pr.del(redis_key)
        pr.lpush(redis_key, *values)
      end
    end

    private

    def redis_base_key(namespace, key)
      "#{@prefix}#{namespace}:#{key}"
    end
  end
end
