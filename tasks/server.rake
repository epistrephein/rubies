# frozen_string_literal: true

namespace :server do
  desc 'Start server in development environment'
  task :dev do
    exec 'bundle exec rerun -- rackup -p ${PORT:-4567} -E ${RACK_ENV:-development} config.ru'
  end
end
