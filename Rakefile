# frozen_string_literal: true

require 'bundler/setup'

Rake.add_rakelib 'tasks/redis'

namespace :start do
  desc 'Start server in development environment'
  task :dev do
    exec 'foreman start -e .env.dev -f Procfile.dev'
  end

  desc 'Start server in test environment'
  task :test do
    exec 'foreman start -e .env.test -f Procfile.test'
  end
end

task default: 'start:dev'
