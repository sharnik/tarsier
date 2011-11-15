require 'rcov'
require 'loris/utils.rb'
require 'loris/result.rb'
require 'loris/base.rb'
require 'loris/report.rb'

require 'loris/railtie.rb' if defined?(Rails) && Rails::VERSION::MAJOR > 2

