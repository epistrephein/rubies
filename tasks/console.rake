# frozen_string_literal: true

desc 'Start development console'
task :console do
  require 'pry'

  Pry.start
rescue LoadError
  require 'irb'

  ARGV.clear
  IRB.start(__FILE__)
end
