# frozen_string_literal: true

require 'fileutils'

app_dir = File.expand_path('..', __dir__)

worker_processes 2
working_directory app_dir

timeout 30

# Create folders
FileUtils.mkdir_p "#{app_dir}/tmp/sockets"
FileUtils.mkdir_p "#{app_dir}/tmp/pids"
FileUtils.mkdir_p "#{app_dir}/log"

# Set socket path for nginx
listen "#{app_dir}/tmp/sockets/unicorn.sock", backlog: 64

# Set process id path
pid "#{app_dir}/tmp/pids/unicorn.pid"

# Set log file paths
stdout_path "#{app_dir}/log/unicorn.stdout.log"
stderr_path "#{app_dir}/log/unicorn.stderr.log"
