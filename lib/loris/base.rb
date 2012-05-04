module Loris
  # Analyzer data from rcov analyzers for all code files.
  accessor :data, {}
  # Actual code lines of code that has been run.
  accessor :code_lines, {}
  # Arguments with which the script is called
  accessor :arguments, {}
  # Files matching any of these will not appear in the output
  accessor :silencers, [/\/gems\//, /\/ruby\//, /\/vendor\//, /\/test\//, /\/spec\//,
    __FILE__, File.expand_path('monkeypatching.rb', File.dirname(__FILE__))]
  accessor :excluded_paths, ['spec/support', 'spec/factories']
  accessor :result

  def self.mode
    if arguments[:file] && arguments[:line_number]
      :line
    else
      :suite
    end
  end

  def self.test_suite_wrapper
    result = yield
    Loris::Report.puke_out_report
    result
  end

  def self.test_method_wrapper(sender)
    analyzer = Rcov::CodeCoverageAnalyzer.new
    analyzer.run_hooked do
      yield
    end
    analyzer.analyzed_files.each do |file|
      next if Loris.silencers.any? {|silencer| silencer === file}
      Loris.data[file] ||= {}
      lines, marked_info, count_info = analyzer.data(file)
      Loris.code_lines[file] = lines
      marked_info.each_with_index do |elem, index|
        Loris.data[file][index] ||= {}
        if elem
          alter_data(file, index, sender) if elem
        end
      end
    end
  end

  # Parses command line options, merges them with defaults and sets as Loris arguments.
  #
  # @param [Hash] env user options
  #
  def self.set_attributes(env)
    defaults = {
      :tests_path => 'spec,test',
      :file => nil,
      :line_number => nil,
      :add_excluded_paths => [],
      :output => nil,
      :add_silencers => []
    }
    keys = defaults.keys
    options = env.reject {|key, _| !keys.include?(key.to_sym) }
    Loris.arguments = Hash[options.map{|k,v| [k.to_sym, v]}]
    filter_attribute(:add_silencers, :attribute_to_regexp_array)
    filter_attribute(:add_excluded_paths, :split_attribute_to_array)

    Loris.arguments = defaults.merge Loris.arguments

    Loris.silencers += Loris.arguments[:add_silencers]
    Loris.excluded_paths += Loris.arguments[:add_excluded_paths]

    Loris.result = Loris::Result.new
  end

  # Main method to run Loris: loads tests and runs them.
  #
  def self.run
    test_files = Loris.arguments[:tests_path].split(',').map do |include_path|
      test_files_in_path(include_path)
    end
    test_files.flatten!

    excluded_test_files = Loris.excluded_paths.map do |exclude_path|
      test_files_in_path(exclude_path)
    end
    excluded_test_files.flatten!

    # Load test files
    (test_files - excluded_test_files).each { |file| require file }

    # Requires our monkeypatching at the end, to make sure it's not overwritten
    require 'loris/monkeypatching.rb'

    if defined? Test::Unit::Runner
      Test::Unit::Runner.new.run()
      Loris::Report.puke_out_report
    end

    if defined? RSpec::Core::Runner
      # Registers a hook to display the Report
      at_exit do
        Loris::Report.puke_out_report
      end
      # Runs loaded RSpec suite
      RSpec::Core::Runner.run( [] )
    end
  end

  private
    def self.alter_data(source_file, index, sender)
      if defined?(RSpec) && sender.class == RSpec::Core::Example
        test_group_name = sender.file_path
        test_name = "#{sender.full_description} - #{sender.location}"
      else
        test_group_name = sender.class.to_s
        test_name = sender.instance_variable_get(:@__name__).to_sym
      end
      Loris.data[source_file][index][test_group_name] ||= []
      Loris.data[source_file][index][test_group_name] << test_name
    end

    def self.test_files_in_path(path)
      if path
        Dir.glob(File.expand_path('**/*.rb', File.expand_path(path, Dir.pwd)))
      else
        []
      end
    end

    def self.filter_attribute(attribute, method)
      return unless Loris.arguments[attribute]
      Loris.arguments[attribute] = send(method, attribute)
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
