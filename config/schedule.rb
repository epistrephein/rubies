# frozen_string_literal: true

set :bundle_command,       '/usr/bin/bundle exec'
set :output,               'log/rake.log'
set :chronic_options,      hours24: true

set :environment_variable, 'REDIS_URL'
set :environment,          'redis://localhost:6379/1'

every 1.hour do
  rake 'redis'
end
