# frozen_string_literal: true

require 'octokit'
require 'rubygems'
require 'json'
require 'yaml'

class Remote
  REPOSITORY   = 'ruby/www.ruby-lang.org'

  STATUSES     = %w[preview normal security eol].freeze
  MIN_VERSION  = '2.1'

  # Abstract class, initialize is implemented in subclasses
  def initialize
    raise "Don't instantiate an abstract class"
  end

  class << self
    private

    # Fetch, decode and parse a remote YAML data file
    def fetch(path)
      remote  = Octokit.contents(REPOSITORY, path: path)
      decoded = Base64.decode64(remote.content)

      YAML.safe_load(decoded, [Date])
    rescue Octokit::Error, Faraday::Error, Psych::SyntaxError => e
      retries ||= 2
      retry if (retries -= 1).positive?

      raise e
    end
  end
end
