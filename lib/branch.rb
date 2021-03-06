# frozen_string_literal: true

class Branch < Remote
  attr_reader :branch, :status, :release_date, :eol_date

  BRANCHES_REF  = ENV.fetch('BRANCHES_REF',  'master')
  BRANCHES_PATH = ENV.fetch('BRANCHES_PATH', '_data/branches.yml')

  STATUSES      = %w[normal security preview eol].freeze

  SCHEMA = {
    'name'     => [String, Float],
    'status'   => [String],
    'date'     => [Date, String, NilClass],
    'eol_date' => [Date, String, NilClass]
  }.freeze

  def initialize(branch, status, release_date, eol_date)
    @branch       = branch
    @status       = status
    @release_date = release_date
    @eol_date     = eol_date
  end

  # Return the latest version of the branch
  def latest
    releases.first
  end

  # Return the releases of the branch
  def releases
    Release.branch(self)
  end

  # Return the branch name as string
  def to_s
    branch.to_s
  end

  # Return the branch attributes as JSON
  def to_json(*_args)
    JSON.generate(attributes)
  end

  # Return the branch attributes as hash
  def attributes
    {
      branch:       to_s,
      status:       status,
      release_date: release_date,
      eol_date:     eol_date,
      latest:       latest.to_s,
      releases:     releases.map(&:to_s)
    }
  end

  class << self
    attr_reader :sha

    # Return the branch with the matching name
    def [](branch)
      all.find { |b| b.branch == branch }
    end

    # Return the branches with the matching status
    def status(*status)
      all.select { |b| status.include?(b.status) }
    end

    # Return all branches attributes as hash
    def hashmap_branches
      all.each_with_object({}) do |branch, hash|
        hash[branch.to_s] = branch.attributes
      end
    end

    # Return all statuses attributes as hash
    def hashmap_statuses
      STATUSES.each_with_object({}) do |status, hash|
        branches = status(status)

        hash[status.to_s] = {
          status:   status,
          branches: branches.map(&:to_s),
          latest:   branches.map { |b| b.latest.to_s }
        }
      end
    end

    # Return the latest 4 branches as string
    def examples_branches(count = 4)
      all.first(count).map(&:to_s)
    end

    # Return all statuses as string
    def examples_statuses
      STATUSES
    end

    # Return 6 releases of the 4 most recent branches as string
    def examples_releases(count = 6)
      all.each_with_object([]).with_index do |(branch, array), index|
        size = [0, 1].include?(index) ? 2 : 1
        array.concat(branch.releases.take(size).map(&:to_s))
      end.first(count)
    end

    # Return all branches
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

      remote = fetch(ref: BRANCHES_REF, path: BRANCHES_PATH)
      @sha   = remote.sha

      content = parse(remote.content)
      raise self::ValidationError unless valid?(content)

      unsorted = content.filter_map do |branch|
        version      = branch['name'].to_s
        status       = branch['status'].match(Regexp.union(STATUSES)).to_s
        release_date = branch['date']
        eol_date     = branch['eol_date']

        next if version < self::ENABLED_MIN

        if version < self::SEMVER_MIN
          version = version.split('.').first(2).join('.')
        end

        Branch.new(version, status, release_date, eol_date)
      end

      @data ||= unsorted.sort_by(&:to_s).reverse
    end
  end
end
