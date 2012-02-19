# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'banker/version'

Gem::Specification.new do |s|
  s.name        = 'banker'
  s.version     = Banker::VERSION
  s.authors     = ['Kyle Welsby', 'Chuck Hardy']
  s.email       = ['app@britishruby.com']
  s.homepage    = 'https://github.com/BritRuby/Banker'
  s.description = %q{A collection of stratagies to access online bank accounts to obtain balance and transaction details.}
  s.summary     = s.description

  s.add_runtime_dependency 'mechanize'
  s.add_runtime_dependency 'ofx'

  s.add_development_dependency 'growl'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'rspec', '~> 2.8'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'cane'

  s.rubyforge_project = 'banker'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

end
