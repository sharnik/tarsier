module Tarsier
  # Arguments with which the script is called
  accessor :arguments, {}
  # Files matching any of these will not appear in the output
  accessor :exclude_path, ['spec/support', 'spec/factories']
  accessor :result
  accessor :data_collector

  def self.mode
    if arguments[:file] && arguments[:line_number]
      :line
    else
      :suite
    end
  end

  # Parses command line options, merges them with defaults and sets as Tarsier arguments.
  #
  # @param [Hash] env user options
  #
  def self.set_attributes(env)
    defaults = {
      :load_path => 'spec,test',
      :exclude_path => [],
      :file => nil,
      :line_number => nil,
      :output => nil,
    }
    keys = defaults.keys
    options = env.reject {|key, _| !keys.include?(key.to_sym) }
    Tarsier.arguments = Hash[options.map{|k,v| [k.to_sym, v]}]    
    filter_attribute(:add_silencers, :attribute_to_regexp_array)
    filter_attribute(:exclude_path, :split_attribute_to_array)

    Tarsier.arguments = defaults.merge Tarsier.arguments

    Tarsier.data_collector = DataCollector.new(
      :silencers => Tarsier.arguments[:add_silencers]
    )
    Tarsier.exclude_path += Tarsier.arguments[:exclude_path]

    Tarsier.result = Result.new
  end

  # Main method to run Tarsier: loads tests and runs them.
  #
  def self.run
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

    def self.load_test_files(options)
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

    def self.test_files_in_path(path)
      if path
        Dir.glob(File.expand_path('**/*.rb', File.expand_path(path, Dir.pwd)))
      else
        []
      end
    end

    def self.filter_attribute(attribute, method)
      return unless Tarsier.arguments[attribute]
      Tarsier.arguments[attribute] = send(method, attribute)
    end

    def self.attribute_to_regexp_array(attribute)
      array = split_attribute_to_array(attribute)
      array.map! do |text|
        text[/^\/(.*)\/$/] ? /#{$1}/ : text
      end
    end

    def self.split_attribute_to_array(attribute)
      return [] if attribute.nil?
      attribute.split(',')
    end

end
