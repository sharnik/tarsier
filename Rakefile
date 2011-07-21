require 'bundler/gem_tasks'
$:.unshift File.expand_path("../lib", __FILE__)

namespace :loris do

  desc "Tests the coverage with Loris"
  task :run, :arg do |t, args|
    options = {
      :tests_path => ENV['tests_path'] || 'test',
      :file => ENV['file'],
      :line_number => ENV['line_number']
    }
    #puts (t.methods.sort - Object.new.methods).inspect
    require 'loris'
    Loris.run(options)
  end
end

