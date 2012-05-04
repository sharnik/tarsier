# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "loris/version"

Gem::Specification.new do |s|
  s.name        = "loris"
  s.version     = Loris::VERSION
  s.authors     = ["Daniel Salmerón Amselem", "Krzysztof Heród", "Wojciech Ogrodowczyk"]
  s.email       = ["wojciech.ogrodowczyk@xing.com"]
  s.homepage    = "http://source.xing.com/wojciech-ogrodowczyk/loris/"
  s.summary     = %q{Simple gem to uncover test duplicates.}
  s.description = %q{This gem uses rcov analyzer to go through your test suite and try to find unnecessary test duplication - code that is over-tested and testcases that do it.}

  s.rubyforge_project = "loris"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rcov', '0.9.11')

  s.add_development_dependency('mocha', '>= 0.9.12')
  s.add_development_dependency('aruba', '>= 0.4.3')
  s.add_development_dependency('require_relative', '>= 1.0.2')
  s.add_development_dependency('rspec', '>= 2.6.0')
  s.add_development_dependency('rake', '>= 0.9.2')
end
