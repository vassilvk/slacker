# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "slacker/version"

Gem::Specification.new do |s|
  s.name        = "slacker"
  s.version     = Slacker::VERSION
  s.authors     = ["Vassil Kovatchev"]
  s.email       = ["vassil.kovatchev@gmail.com"]
  s.homepage    = "https://github.com/vassilvk/slacker/wiki"
  s.summary     = %q{Behavior Driven Development for SQL Server}
  s.description = %q{RSpec-based framework for developing automated tests for SQL Server}
  s.license = 'MIT'

  s.rubyforge_project = "slacker"

  s.files = ['README.markdown', 'Rakefile', 'Gemfile', 'slacker.gemspec'] + Dir.glob("{bin,lib,spec}/**/*")
  s.test_files = Dir.glob("spec/**/*")
  s.executables = ['slacker', 'slacker_new']
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.2'
 
  s.add_dependency 'bundler', '~> 1.0', '>= 1.0.15'
  s.add_dependency 'ruby-odbc', '= 0.99998'
  s.add_dependency 'rspec', '~> 3.0'
  s.add_dependency 'tiny_tds', '~>2.0'
end
