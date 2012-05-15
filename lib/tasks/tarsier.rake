$:.unshift File.expand_path("../lib", File.dirname(__FILE__))

namespace :tarsier do

  desc "Tests the coverage with Tarsier"
  task :run do
    require 'tarsier'

    Tarsier.set_attributes(ENV)
    puts 'Loading Tarsier.'
    Tarsier.run
  end
end

