# frozen_string_literal: true

require 'redis'
require 'time'

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

    Branch.all.each  { |b| REDIS.set(b.to_s, b.to_json) }
    Release.all.each { |r| REDIS.set(r.to_s, r.to_json) }

    Branch::STATUSES.each do |status|
      branches = Branch.status(status)

      REDIS.set(status, {
        status:   status,
        branches: branches.map(&:to_s),
        latest:   branches.map { |b| b.latest.to_s }
      }.to_json)
    end

    REDIS.set('version', { version: VERSION_FULL }.to_json)
    REDIS.set('last_update', { last_update: Time.now.iso8601 }.to_json)
  end
end
