# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "slacker/version"

Gem::Specification.new do |s|
  s.name        = "slacker"
  s.version     = Slacker::VERSION
  s.authors     = ["Vassil Kovatchev"]
  s.email       = ["vassil.kovatchev@gmail.com"]
  s.homepage    = "https://github.com/vassilvk/slacker"
  s.summary     = %q{Behavior Driven Development for SQL Server}
  s.description = %q{RSpec-based framework for developing automated tests for SQL Server programmable objects such as stored procedures and scalar/table functions}

  s.rubyforge_project = "slacker"

  s.files = ['README.markdown', 'Rakefile', 'Gemfile', 'slacker.gemspec', 'Gemfile.lock'] + Dir.glob("{bin,lib,spec}/**/*")
  s.test_files = Dir.glob("spec/**/*")
  s.executables = ['slacker', 'slacker_new']
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.2'
 
  s.add_dependency 'bundler', '~>1.0.15'
  s.add_dependency 'ruby-odbc', '=0.99994'
  s.add_dependency 'rspec', '=2.5.0'
end
