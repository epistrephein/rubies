# frozen_string_literal: true

require 'octokit'
require 'yaml'
require 'redis'
require 'json'
require 'rubygems'

class PopulateRedisService
  REDIS        = Redis.new(url: ENV['REDIS_URL'], db: 1)

  REPOSITORY   = 'ruby/www.ruby-lang.org'
  BRANCHES_YML = '_data/branches.yml'
  RELEASES_YML = '_data/releases.yml'

  NEWER_THAN   = Gem::Version.new('2.0').freeze
  STATUSES     = %w[preview normal security eol].freeze

  attr_reader :releases, :branches

  def redisize
    branches.each do |k, v|
      REDIS.set(k, {
        branch:   v[:branch],
        status:   v[:status],
        latest:   branch_releases(k).keys.first,
        releases: branch_releases(k).keys
      }.to_json)
    end

    releases.each do |k, v|
      REDIS.set(k, {
        release: k,
        branch:  reference_branch(k)[:branch],
        status:  reference_branch(k)[:status],
        latest:  releases.select { |kk, vv| kk =~ /^#{v.segments.first(2).join('.')}/}.keys.first == k
      }.to_json)
    end
  end

  def populate
    # populate redis
    parse_branches
    parse_releases
  end

  def reference_branch(release)
    branches.find { |k, _v| release.to_s =~ /^#{k}/ }&.last
  end

  def grouped_releases
    releases.group_by { |k, _v| reference_branch(k)[:branch] }
  end

  def branch_releases(branch)
    releases.select { |k, _v| k =~ /^#{branch}/ }
  end

  # def branches_entries
  #   branches.keys
  # end

  # def releases_entries
  #   releases
  # end

  def parse_branches
    remote_branches = fetch(BRANCHES_YML)

    @branches = remote_branches.each_with_object({}) do |branch, hash|
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
  end

  def parse_releases
    remote_releases = fetch(RELEASES_YML)

    unsorted_releases = remote_releases.each_with_object({}) do |release, hash|
      version_string     = release['version']
      version_comparable = Gem::Version.new(version_string)
      next if version_comparable <= NEWER_THAN

      hash[version_string] = version_comparable
    end

    @releases = Hash[unsorted_releases.sort_by { |_k, v| v }.reverse]
  end

  def fetch(path)
    remote  = Octokit.contents(REPOSITORY, path: path)
    decoded = Base64.decode64(remote.content)

    YAML.safe_load(decoded, [Date])
  rescue Octokit::Error, Faraday::Error => e
    retries ||= 3
    retry if (retries -= 1).positive?
    raise e
  end
end
