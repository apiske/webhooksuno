# frozen_string_literal: true

class Spyderweb::Bimap
  attr_reader :l, :r

  def initialize
    @l = Hash.new
    @r = Hash.new
  end

  def [](key)
    case key
    when Integer
      r[key]
    when Symbol
      l[key]
    when String
      l[key.to_sym]
    else
      raise "Invalid key class '#{key.class}'"
    end
  end

  def self.create(data)
    new.tap do |b|
      data.each do |l, r|
        b << [l, r]
      end
    end
  end

  def <<(pair)
    raise RuntimeError.new("Expecting a pair") unless pair.size == 2
    @l[pair[0]] = pair[1]
    @r[pair[1]] = pair[0]
  end
end
