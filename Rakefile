require 'bundler/gem_tasks'
$:.unshift File.expand_path("../lib", __FILE__)

namespace :loris do
  
  desc "Tests the coverage with Loris"
  task :run do
    require 'loris'
    Loris.run
  end
end

