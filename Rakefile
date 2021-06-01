# encoding: utf-8
 
# Environment task. Used as a parent task for all tasks that requires access to
# the Sherlock environment.
task :environment do
  $:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
  require 'sherlock'
end

# Database related tasks.
namespace :db do
  desc 'Add seed data to the database'
  task :seed => :environment do
    load File.expand_path(File.join(File.dirname(__FILE__), 'db', 'seed.rb'))
  end
end
