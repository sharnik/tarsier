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
      result = {:collection => [], :mode => Loris.mode}
      groups.each_with_index do |group, index|
        chunk = {}
        if Loris.mode == :line
          chunk[:line] = Loris.arguments[:line_number]
          chunk[:file] = Loris.arguments[:file]
        else
          chunk[:files] = grouped_lines[index].map do |file, lines|
            { :name => file,
              :code => lines.sort.map {|line| "#{line + 1}: #{Loris.code_lines[file][line]}"}
            }
          end
        end
        chunk[:test_groups] = group
        result[:collection] << chunk
      end
      directory = Loris.arguments[:output]
      if directory
        Dir::mkdir(directory) unless FileTest::directory?(directory)
        File.open("#{directory}/index.html", "w") do |f|
          f.write report_to_html
        end
      else
        output = ""
        result[:collection].each_with_index do |chunk, index|
          if result[:mode] == :line
            header = "\nLine #{chunk[:line]} in file #{chunk[:file]}"
            header << " has been touched by #{chunk[:test_groups].length} test case(s): "
          else
            header = "\nThe following files has been touched by #{chunk[:test_groups].length} different test cases: "
          end
          header << chunk[:test_groups].map { |suite, cases| "#{suite} (#{cases.join(', ')})" }.join(', ')
          output << "\n" + header
          if result[:mode] != :line
            chunk[:files].each do |file_data|
              output << "\n" + file_data[:name] + "\n"
              output << file_data[:code].join
            end
          end
        end
        STDOUT.puts output
      end
    end

    private
      def self.report_to_html
        require "erb"
        template_file = File.open(File.expand_path("template/index.html.erb", File.dirname(__FILE__)), "r:UTF-8')
        template = ERB.new(template_file, 0, "%<>")
        output = template.result( Loris.result.get_binding )
      end

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
