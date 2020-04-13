# frozen_string_literal: true

require 'octokit'
require 'yaml'
require 'redis'
require 'json'
require 'rubygems'

REPOSITORY   = 'ruby/www.ruby-lang.org'
BRANCHES_YML = '_data/branches.yml'
RELEASES_YML = '_data/releases.yml'

NEWER_THAN = Gem::Version.new('2.0').freeze

STATUSES = %w[preview normal security eol].freeze

branches_remote  = Octokit.contents(REPOSITORY, path: BRANCHES_YML)
branches_decoded = Base64.decode64(branches_remote.content)
branches_parsed  = YAML.safe_load(branches_decoded, [Date])

releases_remote  = Octokit.contents(REPOSITORY, path: RELEASES_YML)
releases_decoded = Base64.decode64(releases_remote.content)
releases_parsed  = YAML.safe_load(releases_decoded, [Date])

releases = releases_parsed.each_with_object([]) do |release, array|
  version_string     = release['version']
  version_comparable = Gem::Version.new(version_string)
  next if version_comparable <= NEWER_THAN

  array << version_comparable
end.sort.reverse

branches = branches_parsed.each_with_object({}) do |branch, hash|
  version = branch['name'].to_s
  status  = branch['status'].match(Regexp.union(STATUSES)).to_s
  next if version <= NEWER_THAN.to_s || version =~ /^#{NEWER_THAN}/

  hash[version] = {
    branch:       version,
    status:       status,
    release_date: branch['date'],
    eol_date:     branch['eol_date']
  }
end



# rescue Octokit::Error, Faraday::Error => e
#   retries ||= 3
#   retry if (retries -= 1).positive?
#   raise e
# end

