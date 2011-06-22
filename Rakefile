require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rspec/core/rake_task'

spec = Gem::Specification.new do |s|
  s.name = 'slacker'
  s.version = '0.0.1'
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'SQL Server Code Test Platform'
  s.description = 'RSpec-based SQL Server Code Test Platform'
  s.author = 'Vassil Kovatchev'
  s.email = 'vkovatchev@deloitte.com'
  s.executables = ['slacker']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
  # Dependencies
  s.add_dependency 'ruby-odbc', '=0.99994'
  s.add_dependency 'rspec', '=2.5.0'
end

Gem::PackageTask.new(spec) do |p|
  p.need_tar = true
  p.need_zip = true
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

RSpec::Core::RakeTask.new do |t|
  t.fail_on_error = false
  t.pattern = 'spec/**/*.rb'
end
