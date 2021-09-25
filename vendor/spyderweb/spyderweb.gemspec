# frozen_string_literal: true
# require_relative 'lib/spyder/version'

Gem::Specification.new do |s|
  s.name        = 'spyderweb'
  s.version     = '0.0.1'
  s.licenses    = ['MIT']
  s.summary     = "This is an example!"
  s.description = "Much longer explanation of the example!"
  s.authors     = ["Ruby Coder"]
  s.email       = 'rubycoder@example.com'
  s.files       = Dir.glob('lib/**/*.rb')

  s.add_dependency 'zeitwerk'
end
