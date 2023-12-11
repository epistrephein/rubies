# frozen_string_literal: true

job_type :rake, 'cd :path && :database_variable=:database :bundle_command rake :task :output'

set :chronic_options,   hours24: true

set :database_variable, 'REDIS_URL'
set :database,          'redis://localhost:6379/0'

every 1.hour do
  rake 'redis', output: 'log/redis.log'
end
