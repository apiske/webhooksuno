module Spyderweb::Uuid
  InvalidUuidError = Class.new(StandardError)

  UUID_REGEX = /^(\h{8})-(\h{4})-(\h{4})-(\h{4})-(\h{12})$/.freeze

  def self.uuid_bin_to_s(bin)
    # b = bin.split('').map(&:ord).map { |x| x.to_s(0x10) }.join
    # "#{b[0...8]}-#{b[8...12]}-#{b[12...16]}-#{b[16...20]}-#{b[20...38]}"
    "%08x-%04x-%04x-%04x-%04x%08x" % bin.unpack('NnnnnN')
  end

  def self.uuid_s_to_bin(s)
    # s.tr('-', '').split('').each_slice(2).map { |x, y| (x+y).to_i(0x10).chr }.join
    m = s.match(UUID_REGEX)
    raise InvalidUuidError.new("UUID '#{s}' is invalid") unless m
    (m[1] + m[2] + m[3] + m[4] + m[5]).split('').each_slice(2).map { |x, y| (x+y).to_i(0x10).chr }.join
  end
end
