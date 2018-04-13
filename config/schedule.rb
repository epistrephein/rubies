# frozen_string_literal: true

env :PATH, ENV['PATH']

set :environment_variable, 'REDIS_URL'
set :environment,          'redis://localhost:6379'

set :chronic_options, hours24: true
set :output,
    standard: 'log/cron.stdout.log',
    error:    'log/cron.stderr.log'

every 8.hour do
  rake 'redis:populate'
end
