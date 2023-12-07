# frozen_string_literal: true

desc 'Start development server'
task :server do
  exec 'bundle exec rerun -- rackup -p ${PORT:-4567} -E ${RACK_ENV:-development} config.ru'
end
