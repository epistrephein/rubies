# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

STATUSES = %w[preview normal security eol].freeze
SEMVER = /\b
  v?
  (?<major>0|[1-9]\d*)\.                      # major
  (?<minor>0|[1-9]\d*)                        # minor
  (\.(?<patch>0|[1-9]\d*))?                   # patch
  (-(
    (?<build>p\d+)|                           # build
    (?<pre>[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)   # prerelease
  ))?
\b/ix

def scrape_releases
  url = 'https://www.ruby-lang.org/en/downloads/releases/'
  doc = Nokogiri::HTML(OpenURI.open_uri(url))

  versions = doc.css('tr').css('td[1]')[1..-1].map do |v|
    v.text.match(SEMVER).to_s
  end
  versions.reject { |i| i < '1.9' }
end

def scrape_branches
  url = 'https://www.ruby-lang.org/en/downloads/branches/'
  doc = Nokogiri::HTML(OpenURI.open_uri(url))

  versions = doc.css('#content').css('h3')
  infos = doc.css('#content').css('h3+p')

  versions.each_with_object({}).with_index do |(v, hash), i|
    version = v.text.match(SEMVER).values_at(1, 2).join('.')
    branch = infos[i].text.match(Regexp.union(STATUSES)).to_s
    hash[version] = branch
  end
end

def comparable(version)
  semver   = version.match(SEMVER)
  integers = semver.values_at(1, 2, 3).map(&:to_i)
  build    = semver[:build].to_s[/\d+/].to_i
  pre      = case semver[:pre]
             when nil             then 30
             when /rc(\d+)?/      then (Regexp.last_match(1).to_i + 20)
             when /preview(\d+)?/ then (Regexp.last_match(1).to_i + 10)
             else 0
             end
  integers.push(build, pre)
end

def sort(versions)
  versions.sort_by { |v| comparable(v) }.reverse
end

def latest(versions, preview: false)
  sorted = sort(versions)
  sorted.reject! { |v| v =~ /rc|preview/ } unless preview
  sorted.first
end

def branch(branch, preview: false)
  sorted = sort(RELEASES.select { |r| r.match(/^#{branch}/) })
  preview ? sorted : sorted.reject { |v| v =~ /rc|preview/ }
end

def status(status)
  BRANCHES.select { |_k, v| v == status.to_s }.keys
end

def preview
  sort(status('preview').map { |b| latest(branch(b, preview: true), preview: true) })
end

def normal
  sort(status('normal').map { |b| latest(branch(b)) })
end

def security
  sort(status('security').map { |b| latest(branch(b)) })
end

def eol
  sort(status('eol').map { |b| latest(branch(b)) })
end

def active
  normal + security
end

def status?(release)
  mm = release.match(SEMVER).values_at(1, 2).join('.')
  BRANCHES[mm]
end

def latest?(release)
  __send__(status?(release)).include?(release)
end
