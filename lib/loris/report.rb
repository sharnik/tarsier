module Loris

  # Takes care of presenting the analysis results.
  class Report
    attr_accessor :attributes

    # Displays the report on STDOUT.
    #
    # @param [Hash] options for output
    # @return nil
    def self.puke_out_report(options = {})
      groups = []
      Loris.data.each do |file, lines|
        lines.each do |line_number, test_cases|
          if condition(test_cases, file, line_number)
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
        if Loris.mode == :find_files
          header = "\nLine #{Loris.arguments[:line_number]} in file #{Loris.arguments[:file]}"
          header << " has been touched by #{group.length} test case(s): "
        else
          header = "\nThe following files has been touched by #{group.length} different test cases: "
        end
        header << group.map { |suite, cases| "#{suite} (#{cases.join(', ')})" }.join(', ')
        STDOUT.puts header
        if Loris.mode != :find_files
          grouped_lines[index].each do |file, lines|
            STDOUT.puts file
            lines.sort.each do |line|
              STDOUT.puts "#{line + 1}: #{Loris.code_lines[file][line]}"
            end
          end
        end
      end
    end

    private
      def self.condition(test_cases, file, line_number)
        if Loris.mode == :find_files
          file == File.expand_path(Loris.arguments[:file]) && (line_number + 1) == Loris.arguments[:line_number].to_i
        else
          test_cases.length > 1
        end
      end
  end
end
