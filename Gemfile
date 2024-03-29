source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.6', '>= 6.1.6.1'
gem 'tzinfo-data'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 5.6'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1', '>= 3.1.13'

gem 'comff'
gem 'oj'
gem 'msgpack'
gem 'multi_json'
gem 'jwt'
gem 'redis', '< 5'

gem 'rjob', '~> 0.5'
gem 'spyderweb', path: './vendor/spyderweb'

gem 'dry-types'
gem 'dry-struct'
gem 'dry-validation', '~> 1.5'

gem 'excon'
gem 'rack-cors'
gem 'rack-attack'

gem 'nokogiri', '>= 1.13.9'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry'
  gem 'pry-byebug'

  gem 'rspec-rails', '~> 6.0'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  # gem 'web-console', '>= 4.1.0'
  # gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'factory_bot_rails', '~> 6.2'
  gem 'ffaker'
  gem 'timecop'
  gem 'vcr'
  gem 'simplecov', require: false
end
