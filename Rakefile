# vim: fileencoding=utf-8
require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'

task :default => [:test]
task :package => [:clean]

Bundler::GemHelper.install_tasks

Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb", "ext/**/*.c")
end

desc "gem uninstall"
task :uninstall do
  sh "gem uninstall net-github-upload"
end

# vim: syntax=ruby
