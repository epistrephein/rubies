# frozen_string_literal: true

require 'fileutils'

worker_processes 2
working_directory __dir__

timeout 30

# Create folders
FileUtils.mkdir_p "#{__dir__}/tmp/sockets"
FileUtils.mkdir_p "#{__dir__}/tmp/pids"
FileUtils.mkdir_p "#{__dir__}/log"

# Set socket path for nginx
listen "#{__dir__}/tmp/sockets/unicorn.sock", backlog: 64

# Set process id path
pid "#{__dir__}/tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "#{__dir__}/log/unicorn.stderr.log"
stdout_path "#{__dir__}/log/unicorn.stdout.log"
