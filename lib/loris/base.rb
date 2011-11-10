module Loris
  # Analyzer data from rcov analyzers for all code files.
  accessor :data, {}
  # Actual code lines of code that has been run.
  accessor :code_lines, {}
  # Arguments with which the script is called
  accessor :arguments, {}
  # Default values of arguments
  accessor :defaults, {}
  # Files matching any of these will not appear in the output
  accessor :silencers, [/\/gems\//, /\/ruby\//, /\/vendor\//, /\/test\//, /\/spec\//,
    __FILE__, File.expand_path('monkeypatching.rb', File.dirname(__FILE__))]

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
    if sender.class == RSpec::Core::Example
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
            Loris.data[file][index][sender.location] ||= []
            Loris.data[file][index][sender.location] << sender.full_description
          end
        end
      end

    else
      # Basically Test::Unit stuff
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
            Loris.data[file][index][sender.class.to_s] ||= []
            Loris.data[file][index][sender.class.to_s] << sender.method_name.to_sym
          end
        end
      end
    end
  end

  def self.set_attributes(env)
    defaults = {
      :tests_path => 'spec',
      :file => nil,
      :line_number => nil,
      :exclude_paths => 'spec/support,spec/factories',
      :output => nil,
      :add_silencers => []
    }
    keys = defaults.keys
    options = env.reject {|key, _| !keys.include?(key.to_sym) }
    Loris.arguments = Hash[options.map{|k,v| [k.to_sym, v]}]
    filter_attribute(:add_silencers, :attribute_to_regexp_array)
    Loris.arguments = defaults.merge Loris.arguments
  end

  def self.run
    # Loads the test suite
    test_files = test_files_in_path(Loris.arguments[:tests_path])

    excluded_test_files = []
    Loris.arguments[:exclude_paths].split(',').each do |exclude_path|
      excluded_test_files << test_files_in_path(exclude_path)
    end

    test_files.flatten!
    excluded_test_files.flatten!
    
    Loris.silencers += Loris.arguments[:add_silencers]

    (test_files - excluded_test_files).each do |test_file|
      require test_file
    end

    # Requires our monkeypatching later, to make sure it's not overwritten
    require 'loris/monkeypatching.rb'
    
    RSpec::Core::Runner.run []
  end

  private
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
      return [] if attribute.nil?
      array = attribute.split(',')
      array.map! do |text|
        text[/^\/(.*)\/$/] ? /#{$1}/ : text
      end
    end

end
