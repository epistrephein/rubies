# frozen_string_literal: true

require 'fileutils'

APP_DIR = File.expand_path('..', __dir__)

worker_processes 2
working_directory APP_DIR

timeout 30

# Create folders
FileUtils.mkdir_p "#{APP_DIR}/tmp/sockets"
FileUtils.mkdir_p "#{APP_DIR}/tmp/pids"
FileUtils.mkdir_p "#{APP_DIR}/log"

# Set socket path for nginx
listen "#{APP_DIR}/tmp/sockets/unicorn.sock", backlog: 64

# Set process id path
pid "#{APP_DIR}/tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "#{APP_DIR}/log/unicorn.stderr.log"
