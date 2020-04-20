# frozen_string_literal: true

class Release < Remote
  attr_reader :release, :comparable, :release_date

  REMOTE_YML = '_data/releases.yml'

  SCHEMA = {
    'version' => [String, Float],
    'date'    => [Date, String]
  }.freeze

  def initialize(release, comparable, release_date)
    @release      = release
    @comparable   = comparable
    @release_date = release_date
  end

  # Return whether the release is the latest version of the branch
  def latest?
    self == self.class.branch(branch).first
  end

  # Return whether the release is a prerelease
  def prerelease?
    comparable.prerelease?
  end

  # Return the branch of the release
  def branch
    Branch[comparable.segments.first(2).join('.')]
  end

  # Return the branch status of the release
  def status
    branch.status
  end

  # Return the release version as string
  def to_s
    release.to_s
  end

  # Return the release attributes as JSON
  def to_json(*_args)
    JSON.generate(attributes)
  end

  # Return the release attributes as hash
  def attributes
    {
      release:      to_s,
      branch:       branch.to_s,
      status:       status,
      release_date: release_date,
      latest:       latest?,
      prerelease:   prerelease?
    }
  end

  class << self
    # Return the release with the matching version
    def [](release)
      all.find { |r| r.release == release }
    end

    # Return the releases of a branch
    def branch(branch)
      all.select { |r| r.branch == branch }
    end

    # Return all releases attributes as hash
    def hashmap_releases
      all.each_with_object({}) do |release, hash|
        hash[release.to_s] = release.attributes
      end
    end

    # Return all releases
    def all
      data
    end
    alias build! all

    # Purge all cached data
    def purge!
      @data = nil
    end

    private

    # Fetch and memoize remote data
    def data
      return @data if @data

      remote = fetch(REMOTE_YML)
      raise self::ValidationError unless valid?(remote)

      unsorted = remote.filter_map do |release|
        version_string     = release['version']
        version_comparable = Gem::Version.new(version_string)
        release_date       = release['date']

        next if version_string < self::MIN_VERSION

        Release.new(version_string, version_comparable, release_date)
      end

      @data ||= unsorted.sort_by(&:comparable).reverse
    end
  end
end
