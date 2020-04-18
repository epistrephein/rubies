# frozen_string_literal: true

require 'octokit'
require 'rubygems'
require 'json'
require 'yaml'

class Remote
  REPOSITORY   = 'ruby/www.ruby-lang.org'
  MIN_VERSION  = '2.1'

  class ValidationError < StandardError
    def message
      'schema validation failed'
    end
  end

  # Abstract class, initialize is implemented in subclasses
  def initialize
    raise 'abstract classes cannot be instantiated'
  end

  class << self
    private

    # Validate remote data against the class schema
    def valid?(remote)
      remote.is_a?(Array) && remote.all? do |item|
        (self::SCHEMA.keys - item.keys).empty? && item.all? do |key, value|
          self::SCHEMA[key].nil? || self::SCHEMA[key].include?(value.class)
        end
      end
    end

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
