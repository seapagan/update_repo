require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'inch/rake'
require 'wwtd/tasks'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new do |task|
  task.options << 'lib'
end

Inch::Rake::Suggest.new do |suggest|
  suggest.args << '--pedantic'
end

# reek is not compatible with Ruby < 2.0]
if RUBY_VERSION > '2.0'
  require 'reek/rake/task'
  Reek::Rake::Task.new do |t|
    t.fail_on_error = false
    t.verbose       = true
    t.reek_opts     = '-U'
  end
else
  task :reek do
    # Empty task
  end
end

# task default: [:rubocop, :inch, :reek, :spec, :wwtd, :build]
task default: [:spec, :build] # leave the others off until we are more advanced.
