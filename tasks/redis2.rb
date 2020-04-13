# frozen_string_literal: true

require 'redis'

REDIS ||= Redis.new(url: ENV['REDIS_URL'])

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
