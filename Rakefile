#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

namespace :test do

  Rake::TestTask.new(:units) do |t|
    t.libs << "test"
    t.test_files = FileList['test/unit_test*.rb']
  end

  Rake::TestTask.new(:acceptance) do |t|
    t.libs << "test"
    t.test_files = FileList['test/acceptance_test*.rb']
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << "test"
    t.test_files = FileList['test/integration_test*.rb']
  end

  task :default do
    Rake::Task['test:units'].execute
    Rake::Task['test:acceptance'].execute
    Rake::Task['test:integration'].execute
  end

end

task :default => 'test:default'
