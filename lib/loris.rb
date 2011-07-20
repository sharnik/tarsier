require 'test/unit'
require 'rcov'
require 'mocha'
require 'loris/report.rb'
require 'loris/data_collection.rb'
require 'loris/monkeypatching.rb'

Dir.glob(File.expand_path('../test/**/*.rb', File.dirname(__FILE__))) do |test_file|
  require test_file
end
