module Loris

  # Takes care of presenting the analysis results.
  class Report

    # Displays the report on STDOUT.
    #
    # @param [Hash] options for output
    # @return nil
    def self.puke_out_report(options = {})
      groups = []
      Loris.data.each do |file, lines|
        lines.each do |line_number, test_cases|
          if test_cases.length > 1  # the Condition - can be like (ARGV.first == file and ARGV.last == line_number)
            groups << test_cases unless groups.index(test_cases)
          end
        end
      end

      groups.sort! {|a, b| b.keys.length <=> a.keys.length }

      grouped_lines = []
      Loris.data.each do |file, lines|
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
        STDOUT.puts header
        grouped_lines[index].each do |file, lines|
          STDOUT.puts file
          lines.sort.each do |line|
            STDOUT.puts "#{line + 1}: #{Loris.code_lines[file][line]}"
          end
        end
      end
    end
  end

end
