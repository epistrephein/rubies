# frozen_string_literal: true

set :bundle_command,       '/usr/local/bin/bundle exec'
set :output,               'log/rake.log'
set :chronic_options,      hours24: true

set :environment_variable, 'REDIS_URL'
set :environment,          'redis://localhost:6379/0'

every 1.hour do
  rake 'redis:populate'
end
