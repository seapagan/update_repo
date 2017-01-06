# coding: utf-8
# rubocop:disable LineLength
# rubocop:disable Metrics/BlockLength
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'update_repo/version'

Gem::Specification.new do |spec|
  spec.name          = 'update_repo'
  spec.version       = UpdateRepo::VERSION
  spec.required_ruby_version = '>= 1.9.3'
  spec.authors       = ['Grant Ramsay']
  spec.email         = ['seapagan@gmail.com']

  spec.summary       = 'A Simple Gem to keep multiple locally-cloned Git Repositories up to date'
  spec.homepage      = 'http://updaterepo.seapagan.net'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 11.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'inch'
  spec.add_development_dependency 'simplecov', '~> 0.12'
  spec.add_development_dependency 'pullreview-coverage'
  spec.add_development_dependency 'should_not'
  spec.add_development_dependency 'wwtd'

  # The below dependencies require at least Ruby 2 for the latest versions.
  # Below this we fix to the last working versions to keep Ruby 1.9.3 compat or
  # we ignore completely - Reek and Rubocop working in the latest versions is
  # enough since the code base is common.
  spec.add_development_dependency 'reek', '~> 4.5' if RUBY_VERSION >= '2.1'
  spec.add_development_dependency 'rubocop' if RUBY_VERSION >= '2.0'

  if RUBY_VERSION < '2.0'
    spec.add_development_dependency 'json', '= 1.8.3'
    spec.add_development_dependency 'tins', '= 1.6.0'
    spec.add_dependency 'term-ansicolor', '= 1.3.2'
  end

  spec.add_dependency 'colorize'
  spec.add_dependency 'confoog'
  spec.add_dependency 'trollop'
  spec.add_dependency 'versionomy'
end
