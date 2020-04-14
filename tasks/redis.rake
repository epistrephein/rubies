# frozen_string_literal: true

require 'redis'

require_relative '../lib/remote'
require_relative '../lib/branch'
require_relative '../lib/release'
require_relative '../lib/version'

REDIS ||= Redis.new(url: ENV['REDIS_URL'])

namespace :redis do
  desc 'Fetch remote data and populate Redis'
  task :populate do
    Branch.build!
    Release.build!

    Branch.hashmap_statuses.each  { |key, attr| REDIS.set(key, attr.to_json) }
    Branch.hashmap_branches.each  { |key, attr| REDIS.set(key, attr.to_json) }
    Release.hashmap_releases.each { |key, attr| REDIS.set(key, attr.to_json) }

    REDIS.set('version', { version: VERSION_FULL }.to_json)
    REDIS.set('last_update', { last_update: Time.now }.to_json)
  end
end
