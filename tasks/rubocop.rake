# frozen_string_literal: true

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
  nil
end
