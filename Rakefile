# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::Task.define_task(:update) do |t|
  require 'open-uri'

  SOURCE_FILE = 'https://raw.githubusercontent.com/multiformats/multibase/master/multibase.csv'
  SPEC_FILE_FORMAT = 'https://raw.githubusercontent.com/multiformats/multibase/master/tests/test%<index>d.csv'

  File.open(File.join(__dir__, 'lib', 'table.csv'), "wb") do |saved_file|
    open(SOURCE_FILE, "rb") do |read_file|
      saved_file.write(read_file.read)
    end
  end

  (1..6).each do |index|
    File.open(File.join(__dir__, 'test', 'fixtures', format('test%<index>s.csv', index: index)), "wb") do |saved_file|
      open(format(SPEC_FILE_FORMAT, index: index), "rb") do |read_file|
        saved_file.write(read_file.read)
      end
    end
  end
end

task :default => :test
