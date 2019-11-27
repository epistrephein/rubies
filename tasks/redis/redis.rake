# frozen_string_literal: true

require 'redis'
require 'json'

require_relative 'rubylang'

namespace :redis do
  desc 'Populate Redis with data'
  task :populate do
    puts 'Redis: populating...'

    VERSION = '1.0.2'

    RELEASES ||= scrape_releases
    BRANCHES ||= scrape_branches
    REDIS    ||= Redis.new(url: ENV['REDIS_URL'])

    # /version
    REDIS.set('version', { version: VERSION }.to_json)

    # /active
    REDIS.set('active', active.to_json)

    # /normal, /security, /preview, /eol
    STATUSES.each { |k| REDIS.set(k, __send__(k).to_json) }

    # /2.5, /2.4, /2.5/latest, /2.4/latest...
    BRANCHES.each do |k, v|
      b = branch(k, preview: true)
      REDIS.set(k, b.to_json)
      REDIS.set("#{k}/latest", latest(b, preview: (v == 'preview')).to_json)
    end

    # /2.5.1, /2.5.0, /2.4.4, /2.4.3...
    RELEASES.each do |k|
      REDIS.set(k, {
        status: status?(k),
        latest: latest?(k)
      }.to_json)
    end

    # /last_update
    REDIS.set('last_update', { last_update: Time.now }.to_json)

    puts 'Redis: OK'
  end
end
