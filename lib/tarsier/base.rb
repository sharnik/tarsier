module Tarsier
  # Arguments with which the script is called
  accessor :arguments, {}
  # Files matching any of these will not appear in the output
  accessor :exclude_path, ['spec/support', 'spec/factories']
  accessor :data_analyzer
  accessor :data_collector

  class << self

    def mode
      if arguments[:file] && arguments[:line_number]
        :line
      else
        :suite
      end
    end

    def run(env = {})
      set_env_attributes(env)
      load_test_files({
        :load_path => Tarsier.arguments[:load_path].split(','),
        :exclude_path => Tarsier.exclude_path
      })

      # Requires our monkeypatching at the end, to make sure it's not overwritten
      require 'tarsier/monkeypatching.rb'

      if defined? Test::Unit::Runner
        Test::Unit::Runner.new.run()
        Report.puke_out_report
      end

      if defined? RSpec::Core::Runner
        # Registers a hook to display the Report
        at_exit do
          Report.puke_out_report
        end
        # Runs loaded RSpec suite
        RSpec::Core::Runner.run( [] )
      end
    end

    private

    def set_env_attributes(env)
      defaults = {
        :load_path => 'spec,test',
        :exclude_path => [],
        :file => nil,
        :line_number => nil,
        :output => nil,
      }
      options = env.reject {|key, _| !defaults.keys.include?(key.to_sym) }
      Tarsier.arguments = Hash[options.map{|k,v| [k.to_sym, v]}]    

      filter_attribute(:add_silencers, :attribute_to_regexp_array)
      filter_attribute(:exclude_path, :split_attribute_to_array)

      Tarsier.arguments = defaults.merge Tarsier.arguments

      Tarsier.data_analyzer = DataAnalyzer.new
      Tarsier.data_collector = DataCollector.new(
        :silencers => Tarsier.arguments[:add_silencers]
      )
      Tarsier.exclude_path += Tarsier.arguments[:exclude_path]
    end

    def load_test_files(options)
      test_files = options[:load_path].map do |include_path|
        test_files_in_path(include_path)
      end
      test_files.flatten!

      excluded_test_files = options[:exclude_path].map do |exclude_path|
        test_files_in_path(exclude_path)
      end
      excluded_test_files.flatten!

      (test_files - excluded_test_files).each { |file| require file }
    end

    def test_files_in_path(path)
      if path
        Dir.glob(File.expand_path('**/*.rb', File.expand_path(path, Dir.pwd)))
      else
        []
      end
    end

    def filter_attribute(attribute, method)
      return unless Tarsier.arguments[attribute]
      Tarsier.arguments[attribute] = send(method, attribute)
    end

    def attribute_to_regexp_array(attribute)
      array = split_attribute_to_array(attribute)
      array.map! do |text|
        text[/^\/(.*)\/$/] ? /#{$1}/ : text
      end
    end

    def split_attribute_to_array(attribute)
      return [] if attribute.nil?
      attribute.split(',')
    end

  end

end
