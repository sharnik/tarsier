module Tarsier
  class DataCollector

    attr_accessor :code_lines
    attr_accessor :data
    attr_accessor :silencers

    def initialize(options = {})
      @code_lines = {}
      @data = {}
      @silencers = [/\/gems\//, /\/ruby\//, /\/vendor\//, /\/test\//, /\/spec\//,
        __FILE__, File.expand_path('monkeypatching.rb', File.dirname(__FILE__))]
      @silencers << options[:silencers]
    end

    def test_method_wrapper(sender)
      analyzer = Rcov::CodeCoverageAnalyzer.new
      analyzer.run_hooked do
        yield
      end
      analyzer.analyzed_files.each do |file|
        next if silencers.any? {|silencer| silencer === file}
        data[file] ||= {}
        lines, marked_info, count_info = analyzer.data(file)
        code_lines[file] = lines
        marked_info.each_with_index do |elem, index|
          data[file][index] ||= {}
          if elem
            alter_data(file, index, sender) if elem
          end
        end
      end
    end

    def test_suite_wrapper
      result = yield
      Report.puke_out_report
    end

    private

    def alter_data(source_file, index, sender)
      if defined?(RSpec) && sender.class == RSpec::Core::Example
        test_group_name = sender.file_path
        test_name = "#{sender.full_description} - #{sender.location}"
      else
        test_group_name = sender.class.to_s
        test_name = sender.instance_variable_get(:@__name__).to_sym
      end
      data[source_file][index][test_group_name] ||= []
      data[source_file][index][test_group_name] << test_name
    end


  end
end
