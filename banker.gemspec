# -*- encoding: utf-8 -*-
require File.expand_path('../lib/banker/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors     = ['Kyle Welsby']
  gem.email       = ['kyle@mekyle.com']
  gem.homepage    = 'https://github.com/kylewelsby/Banker'
  gem.description = %q{A collection of strategies to access online bank accounts to obtain balance and transaction details.}
  gem.summary     = gem.description

  gem.add_runtime_dependency 'mechanize'
  gem.add_runtime_dependency 'banker-ofx'

  gem.add_development_dependency "gem-release"
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'vcr'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.name          = "banker"
  gem.require_paths = ['lib']
  gem.version       = Banker::VERSION
end
