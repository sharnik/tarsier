$:.unshift File.expand_path("../lib", File.dirname(__FILE__))

namespace :loris do

  desc "Tests the coverage with Loris"
  task :run do
    require 'loris'

    Loris.set_attributes(ENV)
    puts 'Loading Loris.'
    Loris.run
  end
end

