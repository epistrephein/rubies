# frozen_string_literal: true

require 'fileutils'

APP_DIR = File.expand_path('..', __dir__)

# Set the environment and application directory
environment ENV.fetch('RACK_ENV', 'development')
directory APP_DIR

# Load the Rack application
rackup File.expand_path('../config.ru', __dir__)

if ENV['RACK_ENV'] == 'production'
  # Create folders
  FileUtils.mkdir_p "#{APP_DIR}/tmp/sockets"
  FileUtils.mkdir_p "#{APP_DIR}/tmp/pids"
  FileUtils.mkdir_p "#{APP_DIR}/log"

  # Set workers and threads
  workers Integer(ENV.fetch('PUMA_WORKERS', 2))
  threads_count = Integer(ENV.fetch('PUMA_THREADS', 5))
  threads threads_count, threads_count

  # Set socket and PID paths
  bind "unix://#{APP_DIR}/tmp/sockets/puma.sock"
  pidfile "#{APP_DIR}/tmp/pids/puma.pid"
end
