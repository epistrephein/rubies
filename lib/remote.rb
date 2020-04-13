# frozen_string_literal: true

require 'json'
require 'octokit'
require 'rubygems'
require 'yaml'

class Remote
  REPOSITORY   = 'ruby/www.ruby-lang.org'

  STATUSES     = %w[preview normal security eol].freeze
  NEWER_THAN   = Gem::Version.new('2.0').freeze # TODO: find better way

  def initialize
    raise "Don't instantiate an abstract class"
  end

  def to_json(*_args)
    JSON.generate(attributes)
  end

  def to_yaml(*_args)
    YAML.dump(attributes)
  end

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
