require 'rcov'
require 'erb'

require 'tarsier/utils.rb'
require 'tarsier/result.rb'
require 'tarsier/base.rb'
require 'tarsier/report.rb'

require 'tarsier/railtie.rb' if defined?(Rails) && Rails::VERSION::MAJOR > 2

