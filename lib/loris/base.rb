module Loris
  # Holds analyzer data from rcov analyzers for all code files.
  accessor :data, {}
  # Holds actual code lines of code that has been run.
  accessor :code_lines, {}
  # Arguments with which the script is called
  accessor :arguments, {}
  # Files matching any of these will not appear in the output
  accessor :silencers, [/gems/, /ruby/, /_test\.rb/,
    __FILE__, File.expand_path('monkeypatching.rb', File.dirname(__FILE__))]

  def self.mode
    if arguments[:file] and arguments[:line_number]
      :find_files
    else
      :collect_tests
    end
  end

  def self.test_case_wrapper
    result = yield
    Loris::Report.puke_out_report
    result
  end

  def self.test_suite_wrapper(sender)
    analyzer = Rcov::CodeCoverageAnalyzer.new
    analyzer.run_hooked do
      yield
    end
    analyzer.analyzed_files.each do |file|
      next if Loris.silencers.index {|silencer| silencer === file}
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
