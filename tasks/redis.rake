# frozen_string_literal: true

desc 'Fetch remote data and populate Redis'
task :redis do
  Branch.build!
  Release.build!

  last_update = Time.now

  # Internal use
  REDIS.del(REDIS.keys('rubies:web:*'))

  normal   = Branch.hashmap_statuses.dig('normal',   :latest)
  security = Branch.hashmap_statuses.dig('security', :latest)
  REDIS.rpush('rubies:web:normal',   normal)   if normal.any?
  REDIS.rpush('rubies:web:security', security) if security.any?

  REDIS.rpush('rubies:web:statuses_ex', Branch.examples_statuses)
  REDIS.rpush('rubies:web:branches_ex', Branch.examples_branches)
  REDIS.rpush('rubies:web:releases_ex', Branch.examples_releases)

  REDIS.set('rubies:web:last_update', last_update)

  # API endpoints
  Branch.hashmap_statuses.each  { |key, attr| REDIS.set("rubies:api:#{key}", attr.to_json) }
  Branch.hashmap_branches.each  { |key, attr| REDIS.set("rubies:api:#{key}", attr.to_json) }
  Release.hashmap_releases.each { |key, attr| REDIS.set("rubies:api:#{key}", attr.to_json) }

  REDIS.set('rubies:api:last_update', { last_update: last_update }.to_json)

  puts "#{last_update}: Redis OK (#{REDIS.dbsize})"
end
