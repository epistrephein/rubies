# frozen_string_literal: true

class Release < Remote
  REMOTE_YML = '_data/releases.yml'

  attr_reader :release, :comparable, :release_date

  def initialize(release, comparable, release_date)
    @release      = release
    @comparable   = comparable
    @release_date = release_date
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
    def [](release)
      all.find { |r| r.release == release }
    end

    def branch(branch)
      all.select { |r| r.branch == branch }
    end

    def dict_releases
      all.each_with_object({}) do |release, hash|
        hash[release.to_s] = release.attributes
      end
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
        release_date       = release['date']

        next if version_string < self::MIN_VERSION

        Release.new(version_string, version_comparable, release_date)
      end

      @data ||= unsorted.compact.sort_by(&:comparable).reverse
    end
  end
end
