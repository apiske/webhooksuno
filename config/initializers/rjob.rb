# frozen_literal_string; true

Rjob.configure do |c|
  c[:redis] = {
    url: Comff.get_str!('app.rjob.url')
  }

  c[:max_threads] = Comff.get_int('app.rjob.max_threads', 1)
  c[:prefix] = Comff.get_str('app.rjob.prefix', 'api2rjob')
  c[:logger] = Rails.logger
end
