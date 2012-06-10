require 'rcov'
require 'erb'

require 'tarsier/utils.rb'
require 'tarsier/base.rb'
require 'tarsier/data_analyzer.rb'
require 'tarsier/data_collector.rb'
require 'tarsier/report.rb'

require 'tarsier/railtie.rb' if defined?(Rails) && Rails::VERSION::MAJOR > 2

