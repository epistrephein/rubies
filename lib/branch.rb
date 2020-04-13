# frozen_string_literal: true

class Branch < Remote
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

    def all
      data
    end
    alias build! all

    private

    def data
      return @data if @data

      remote  = fetch(REMOTE_YML)
      @data ||= remote.map do |branch|
        version     = branch['name'].to_s
        status      = branch['status'].match(Regexp.union(self::STATUSES)).to_s
        branch_date = branch['date']
        eol_date    = branch['eol_date']

        next if version < self::MIN_VERSION

        Branch.new(version, status, branch_date, eol_date)
      end.compact
    end
  end
end
