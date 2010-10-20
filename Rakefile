require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'

desc 'Default: run tests.'
task :default => :test

desc 'Test the liquid_cms gem.'
task :test => ['test:unit', 'test:functional', 'test:integration']

%w(unit functional integration).each do |test|
  desc "Run the #{test} tests for the liquid_cms gem."
  Rake::TestTask.new("test:#{test}") do |t|
    t.pattern = "test/#{test}/*_test.rb"
    t.verbose = true
  end
end
