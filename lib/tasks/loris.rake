$:.unshift File.expand_path("../lib", File.dirname(__FILE__))

namespace :loris do

  desc "Tests the coverage with Loris"
  task :run do
    require 'loris'

    at_exit do
      Loris::Report.puke_out_report
    end

    options = Loris.filter_attributes(ENV)

    puts 'Loading Loris, without extra test helpers.'
    Loris.run(options)
  end
end

