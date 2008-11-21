#!/usr/bin/env ruby
require "fileutils"

Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

# Modifided from the RSpec on Rails plugins
PLUGIN_ROOT = File.expand_path(File.dirname(__FILE__))
REDMINE_APP = File.expand_path(File.dirname(__FILE__) + '/../../../app')
REDMINE_LIB = File.expand_path(File.dirname(__FILE__) + '/../../../lib')

# In rails 1.2, plugins aren't available in the path until they're loaded.
# Check to see if the rspec plugin is installed first and require
# it if it is.  If not, use the gem version.
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)

require 'rake'
require 'rake/clean'
require 'rake/rdoctask'

PROJECT_NAME = 'redmine_exception_handler_plugin'
REDMINE_PROJECT_NAME = 'redmine-exception'
CLEAN.include('**/semantic.cache', "**/#{PROJECT_NAME}.zip", "**/#{PROJECT_NAME}.tar.gz")

# No Database needed
spec_prereq = :noop
task :noop do
end

task :default => :spec

desc 'Generate documentation for the plugin.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = PROJECT_NAME
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end


namespace :release do
  desc "Create a zip archive"
  task :zip => [:clean] do
    sh "git archive --format=zip --prefix=#{PROJECT_NAME}/ HEAD > #{PROJECT_NAME}.zip"
  end

  desc "Create a tarball archive"
  task :tarball => [:clean] do
    sh "git archive --format=tar --prefix=#{PROJECT_NAME}/ HEAD | gzip > #{PROJECT_NAME}.tar.gz"
  end

  desc 'Uploads project documentation'
  task :upload_doc => ['spec:rcov', :doc, 'spec:htmldoc'] do |t|
    # TODO: Get rdoc working without frames
    `scp -r doc/ dev.littlestreamsoftware.com:/home/websites/projects.littlestreamsoftware.com/shared/embedded_docs/#{REDMINE_PROJECT_NAME}/doc`
    `scp -r coverage/ dev.littlestreamsoftware.com:/home/websites/projects.littlestreamsoftware.com/shared/embedded_docs/#{REDMINE_PROJECT_NAME}/coverage`
  end
end
