require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.fail_on_error = false
  t.pattern = 'spec/**/*.rb'
end
