$:.unshift File.expand_path("../lib", File.dirname(__FILE__))

namespace :loris do

  desc "Tests the coverage with Loris"
  task :run do
    options = {
      :tests_path => ENV['tests_path'] || 'spec',
      :file => ENV['file'],
      :line_number => ENV['line_number'],
      :exclude_paths => ENV['exclude_paths'] || ''
    }
    require 'loris'

    puts 'Loading Loris, without extra test helpers.'

    Loris.run(options)
  end
end

