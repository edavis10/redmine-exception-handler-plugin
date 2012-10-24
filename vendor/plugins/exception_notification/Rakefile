require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

unless File.exists? "test/dummy/db/test.sqlite3"
  sh "cd test/dummy; rake db:migrate; rake db:test:prepare; cd ../../;"
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task :default => :test
