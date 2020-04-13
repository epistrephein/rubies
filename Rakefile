# frozen_string_literal: true

require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Rake.add_rakelib 'tasks/**'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

task default: 'server:dev'
