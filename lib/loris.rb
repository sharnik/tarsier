require 'test/unit'
require 'rcov'
require 'mocha'

module Overlaps
  @@data = {}
  def self.data
    @@data
  end

  @@code_lines = {}
  def self.code_lines
    @@code_lines
  end

  class Report
    def self.puke_out_report

      groups = []
      Overlaps.data.each do |file, lines|
        lines.each do |line_number, test_cases|
          if test_cases.length > 1  # the Condition - can be like (ARGV.first == file and ARGV.last == line_number)
            groups << test_cases unless groups.index(test_cases)
          end
        end
      end

      groups.sort! {|a, b| b.keys.length <=> a.keys.length }

      grouped_lines = []
      Overlaps.data.each do |file, lines|
        lines.each do |line_number, test_cases|
          group_id = groups.index(test_cases)
          unless group_id.nil?
            grouped_lines[group_id] ||= {}
            grouped_lines[group_id][file] ||= []
            grouped_lines[group_id][file] << line_number
          end
        end
      end

      groups.each_with_index do |group, index|
        header = "\nThe following files has been touched by #{group.length} different test cases: "
        header << group.map { |suite, cases| "#{suite} (#{cases.join(', ')})" }.join(', ')
        puts header
        grouped_lines[index].each do |file, lines|
          puts file
          lines.sort.each do |line|
            puts "#{line + 1}: #{Overlaps.code_lines[file][line]}"
          end
        end
      end
    end
  end
end

module Test
  module Unit
    class AutoRunner
      alias :run_without_analyzer :run
      def run
        result = run_without_analyzer
        Overlaps::Report.puke_out_report
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
          next if file =~ /gems/ || file =~ /ruby-1.8.7-p334/ || file =~ /_test\.rb/
          Overlaps.data[file] ||= {}
          lines, marked_info, count_info = analyzer.data(file)
          Overlaps.code_lines[file] = lines
          marked_info.each_with_index do |elem, index|
            Overlaps.data[file][index] ||= {}
            if elem
              Overlaps.data[file][index][self.class.to_s] ||= []
              Overlaps.data[file][index][self.class.to_s] << self.method_name.to_sym
            end
          end
        end
      end
    end
  end
end

Dir.glob(File.expand_path('../test/**/*.rb', File.dirname(__FILE__))) do |test_file|
  require test_file
end
