# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'inch/rake'

RSpec::Core::RakeTask.new(:spec)

# rubocop
require 'rubocop/rake_task'
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-performance'
  task.fail_on_error = false
end

Inch::Rake::Suggest.new do |suggest|
  suggest.args << '--pedantic'
end

# reek
require 'reek/rake/task'
Reek::Rake::Task.new do |t|
  t.fail_on_error = false
  t.verbose       = true
  t.reek_opts     = '-U'
end

task default: [:rubocop, :reek, :spec, :inch, :build]
