# frozen_string_literal: true

require 'rubygems'
require 'octokit'
require 'yaml'
require 'json'

class Base
  REPOSITORY   = 'ruby/www.ruby-lang.org'

  STATUSES     = %w[preview normal security eol].freeze
  NEWER_THAN   = Gem::Version.new('2.0').freeze # TODO: find better way

  class << self
    private

    def fetch(path)
      remote  = Octokit.contents(REPOSITORY, path: path)
      decoded = Base64.decode64(remote.content)

      YAML.safe_load(decoded, [Date])
    rescue Octokit::Error, Faraday::Error => e
      retries ||= 2
      retry if (retries -= 1).positive?

      raise e
    end
  end
end

class Branch < Base
  REMOTE_YML = '_data/branches.yml'

  attr_reader :branch, :status, :release_date, :eol_date

  def initialize(branch, status, release_date, eol_date)
    @branch       = branch
    @status       = status
    @release_date = release_date
    @eol_date     = eol_date
  end

  def to_s
    branch.to_s
  end

  def latest
    releases.first
  end

  def releases
    Release.branch(self)
  end

  def to_json(*_args) # TODO: add release_date and eol_date
    {
      branch:   to_s,
      status:   status,
      latest:   latest.to_s,
      releases: releases.map(&:to_s)
    }.to_json
  end

  class << self
    def [](branch)
      all.find { |b| b.branch == branch }
    end

    def status(*status)
      all.select { |b| status.include?(b.status) }
    end

    def all
      data
    end

    alias build! all

    private

    def data
      return @data if @data

      remote  = fetch(REMOTE_YML)
      @data ||= remote.map do |branch|
        version = branch['name'].to_s
        status  = branch['status'].match(Regexp.union(self::STATUSES)).to_s
        next if version <= self::NEWER_THAN.to_s || version =~ /^#{self::NEWER_THAN}/

        Branch.new(version, status, branch['date'], branch['eol_date'])
      end.compact
    end
  end
end

class Release < Base
  REMOTE_YML = '_data/releases.yml'

  attr_reader :release, :comparable

  def initialize(release, comparable = nil)
    @release    = release
    @comparable = comparable || Gem::Version.new(release)
  end

  def latest?
    self == self.class.branch(branch).first
  end

  def prerelease?
    comparable.prerelease?
  end

  def branch
    Branch[comparable.segments.first(2).join('.')]
  end

  def status
    branch.status
  end

  def to_s
    release.to_s
  end

  def to_json(*_args)
    {
      release:    to_s,
      branch:     branch.to_s,
      status:     status,
      latest:     latest?,
      prerelease: prerelease?
    }.to_json
  end

  class << self
    def [](release)
      all.find { |r| r.release == release }
    end

    def branch(branch)
      all.select { |r| r.branch == branch }
    end

    def all
      data
    end

    alias build! all

    private

    def data
      return @data if @data

      remote   = fetch(REMOTE_YML)
      unsorted = remote.map do |release|
        version_string     = release['version']
        version_comparable = Gem::Version.new(version_string)
        next if version_comparable <= self::NEWER_THAN

        Release.new(version_string, version_comparable)
      end

      @data ||= unsorted.compact.sort_by(&:comparable).reverse
    end
  end
end
