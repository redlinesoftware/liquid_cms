require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'

desc 'Default: run tests.'
task :default => :test

test_types = %w(unit functional integration)

desc 'Test the liquid_cms gem.'
task :test => test_types.collect{|t| ["test:#{t}", "test:#{t}:no_context"]}.flatten

test_types.each do |test|
  desc "Run the #{test} tests for the liquid_cms gem"
  Rake::TestTask.new("test:#{test}") do |t|
    t.pattern = "test/#{test}/*_test.rb"
    t.verbose = true
  end
end

test_types.each do |test|
  desc "Run the #{test} tests for the liquid_cms gem (no context)"
  Rake::TestTask.new("test:#{test}:no_context") do |t|
    t.pattern = "test/#{test}/*_test_no_context.rb"
    t.verbose = true
  end
end
