# frozen_string_literal: true

require 'redis'

require_relative '../lib/remote'
require_relative '../lib/branch'
require_relative '../lib/release'

REDIS ||= Redis.new(url: ENV['REDIS_URL'])

namespace :redis do
  desc 'Fetch remote data and populate Redis'
  task :populate do
    Branch.build!
    Release.build!

    last_update = Time.now

    # Internal use
    REDIS.del(%w[__normal __security __statuses_ex __branches_ex __releases_ex])

    normal   = Branch.hashmap_statuses.dig('normal',   :latest)
    security = Branch.hashmap_statuses.dig('security', :latest)
    REDIS.rpush('__normal',   normal)   if normal.any?
    REDIS.rpush('__security', security) if security.any?

    REDIS.rpush('__statuses_ex', Branch.examples_statuses)
    REDIS.rpush('__branches_ex', Branch.examples_branches)
    REDIS.rpush('__releases_ex', Branch.examples_releases)

    REDIS.set('__branches_sha', Branch.sha)
    REDIS.set('__releases_sha', Release.sha)

    REDIS.set('__last_update', last_update)

    # API endpoints
    Branch.hashmap_statuses.each  { |key, attr| REDIS.set(key, attr.to_json) }
    Branch.hashmap_branches.each  { |key, attr| REDIS.set(key, attr.to_json) }
    Release.hashmap_releases.each { |key, attr| REDIS.set(key, attr.to_json) }

    REDIS.set('last_update', { last_update: last_update }.to_json)

    puts "#{last_update}: Redis OK (#{REDIS.dbsize})"
  end
end
