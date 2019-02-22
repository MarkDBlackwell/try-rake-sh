#!/usr/bin/env ruby
# coding: utf-8

desc "Run tests"
task(:test) do
  require 'rake/testtask'
  Rake::TestTask.new(:test) do |t|
    t.test_files = FileList['test/**/*_test.rb']
    t.verbose = true
    t.warning = true
  end
end

task default: [:test]
