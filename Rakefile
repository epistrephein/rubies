# frozen_string_literal: true

require 'bundler/setup'

require_relative 'lib/remote'
require_relative 'lib/branch'
require_relative 'lib/release'

require 'redis'
REDIS ||= Redis.new(url: ENV['REDIS_URL'])

Rake.add_rakelib 'tasks/**'

task default: 'server'
