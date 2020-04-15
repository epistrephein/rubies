# frozen_string_literal: true

class Branch < Remote
  attr_reader :branch, :status, :release_date, :eol_date

  REMOTE_YML = '_data/branches.yml'
  STATUSES   = %w[preview normal security eol].freeze

  SCHEMA = {
    'name'     => [String, Float],
    'status'   => [String],
    'date'     => [Date, String],
    'eol_date' => [Date, String, NilClass]
  }.freeze

  def initialize(branch, status, release_date, eol_date)
    @branch       = branch
    @status       = status
    @release_date = release_date
    @eol_date     = eol_date
  end

  def latest
    releases.first
  end

  def releases
    Release.branch(self)
  end

  def to_s
    branch.to_s
  end

  # Dump attributes as JSON string
  def to_json(*_args)
    JSON.generate(attributes)
  end

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
    def [](branch)
      all.find { |b| b.branch == branch }
    end

    def status(*status)
      all.select { |b| status.include?(b.status) }
    end

    def hashmap_branches
      all.each_with_object({}) do |branch, hash|
        hash[branch.to_s] = branch.attributes
      end
    end

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

    def all
      data
    end
    alias build! all

    def purge!
      @data = nil
    end

    private

    def data
      return @data if @data

      remote = fetch(REMOTE_YML)
      raise self::ValidationError unless valid?(remote)

      @data ||= remote.map do |branch|
        version     = branch['name'].to_s
        status      = branch['status'].match(Regexp.union(STATUSES)).to_s
        branch_date = branch['date']
        eol_date    = branch['eol_date']

        next if version < self::MIN_VERSION

        Branch.new(version, status, branch_date, eol_date)
      end.compact
    end
  end
end
