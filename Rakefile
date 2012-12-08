require 'bundler'
require 'rspec/core/rake_task'
require 'yard'

desc "Build gem"
task :build do
   system("gem build apitrary-client.gemspec")
end

desc "Install gem locally"
task :install do
   system("gem install ./apitrary-client*.gem")
end

# see http://duckpunching.com/rspec-2-0-rake-tasks
desc "Run specs (tests)"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  t.rspec_opts = ['--options', 'spec/spec.opts']
end

YARD::Rake::YardocTask.new

task :default => [:spec]
