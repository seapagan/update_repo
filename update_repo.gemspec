# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'update_repo/version'

Gem::Specification.new do |spec|
  spec.name          = 'update_repo'
  spec.version       = UpdateRepo::VERSION
  spec.required_ruby_version = '>= 2.6.0'
  spec.authors       = ['Grant Ramsay']
  spec.email         = ['seapagan@gmail.com']

  spec.summary       = 'A Simple Gem to keep multiple locally-cloned Git Repositories up to date'
  spec.homepage      = 'http://updaterepo.seapagan.net'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'coveralls_reborn'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'inch'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pullreview-coverage'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'should_not'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'solargraph'
  spec.add_development_dependency 'wwtd'

  # production dependencies
  spec.add_dependency 'colorize'
  spec.add_dependency 'confoog'
  spec.add_dependency 'optimist'
  spec.add_dependency 'versionomy'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
