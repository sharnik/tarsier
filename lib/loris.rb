require 'test/unit'
require 'rcov'
require 'mocha'
require 'loris/utils.rb'
require 'loris/report.rb'
require 'loris/data_collection.rb'
require 'loris/monkeypatching.rb'

Loris.arguments = {:file => ARGV.first, :line_number => ARGV.last}

Dir.glob(File.expand_path('test/**/*.rb', Dir.pwd)) do |test_file|
  require test_file
end
