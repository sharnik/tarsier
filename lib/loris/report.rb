module Loris

  # Takes care of presenting the analysis results.
  class Report
    attr_accessor :attributes

    # Displays the report on STDOUT.
    #
    # @param [Hash] options for output
    # @return nil
    def self.puke_out_report
      groups = test_case_groups(Loris.data)
      groups.sort! {|a, b| b.keys.length <=> a.keys.length }
      grouped_lines = data_grouped(Loris.data, groups)
      output = ""
      groups.each_with_index do |group, index|
        if Loris.mode == :line
          header = "\nLine #{Loris.arguments[:line_number]} in file #{Loris.arguments[:file]}"
          header << " has been touched by #{group.length} test case(s): "
        else
          header = "\nThe following files has been touched by #{group.length} different test cases: "
        end
        header << group.map { |suite, cases| "#{suite} (#{cases.join(', ')})" }.join(', ')
        output << "\n" + header
        if Loris.mode != :line
          grouped_lines[index].each do |file, lines|
            output << "\n" + file + "\n"
            lines.sort.each do |line|
              output << "#{line + 1}: #{Loris.code_lines[file][line]}"
            end
          end
        end
      end
      if Loris.arguments[:output]
        File.open(Loris.arguments[:output], "w") do |f|
          f.write output
        end
      else
        STDOUT.puts output
      end
    end

    private
      def self.condition(test_cases, file, line_number)
        if Loris.mode == :line
          file == File.expand_path(Loris.arguments[:file]) && (line_number + 1) == Loris.arguments[:line_number].to_i
        else
          test_cases.length > 1
        end
      end

      def self.test_case_groups(data)
        groups = []
        Loris.data.each do |file, lines|
          lines.each do |line_number, test_cases|
            if condition(test_cases, file, line_number)
              groups << test_cases unless groups.index(test_cases)
            end
          end
        end
        groups
      end

      def self.data_grouped(data, groups)
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
        grouped_lines
      end
  end
end
