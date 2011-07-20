module Test
  module Unit
    class AutoRunner
      alias :run_without_analyzer :run
      def run
        result = run_without_analyzer
        Loris::Report.puke_out_report
        result
      end
    end
  end
end

module Test
  module Unit
    class TestCase
      alias :run_without_analyzer :run
      def run(*args, &block)
        analyzer = Rcov::CodeCoverageAnalyzer.new
        analyzer.run_hooked do
          run_without_analyzer(*args, &block)
        end
        analyzer.analyzed_files.each do |file|
          next if file =~ /gems/ || file =~ /ruby/ || file =~ /_test\.rb/ || file =~ /loris\/monkeypatching.rb/
          Loris.data[file] ||= {}
          lines, marked_info, count_info = analyzer.data(file)
          Loris.code_lines[file] = lines
          marked_info.each_with_index do |elem, index|
            Loris.data[file][index] ||= {}
            if elem
              Loris.data[file][index][self.class.to_s] ||= []
              Loris.data[file][index][self.class.to_s] << self.method_name.to_sym
            end
          end
        end
      end
    end
  end
end

