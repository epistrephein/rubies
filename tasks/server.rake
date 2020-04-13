# frozen_string_literal: true

namespace :server do
  desc 'Start server in development environment'
  task :dev do
    exec 'foreman start -e .env.dev -f Procfile.dev'
  end
end
