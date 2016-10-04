# coding: utf-8
# rubocop:disable LineLength
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

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'json', '= 1.8.3'
  spec.add_development_dependency 'tins', '= 1.6.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'inch'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'pullreview-coverage'
  spec.add_development_dependency 'should_not'
  spec.add_development_dependency 'wwtd'

  spec.add_dependency 'colorize'
  spec.add_dependency 'confoog'
  spec.add_dependency 'trollop'
  # on Ruby 1.9.3 we lock the 'term-ansicolor' gem to very 1.3.2
  spec.add_dependency 'term-ansicolor', '= 1.3.2' if RUBY_VERSION < '2.0'

  # Depends on Ruby version if we can use 'Reek'
  spec.add_development_dependency 'reek', '~> 3.3' if RUBY_VERSION >= '2.0'
  # Depends on Ruby version if we can use 'rubocop'
  spec.add_development_dependency 'rubocop' if RUBY_VERSION >= '2.0'
end
