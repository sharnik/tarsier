require 'rcov'
require 'loris/utils.rb'
require 'loris/base.rb'
require 'loris/report.rb'

Loris.arguments = {:file => ARGV.first, :line_number => ARGV.last}
