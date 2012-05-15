module Tarsier
  # Takes care of presenting the analysis results.
  class Report
    attr_accessor :attributes

    # Displays the report on STDOUT.
    #
    # @param [Hash] options for output
    # @return nil
    def self.puke_out_report
      groups = test_case_groups(Tarsier.data)
      groups.sort! {|a, b| b.keys.length <=> a.keys.length }
      grouped_lines = data_grouped(Tarsier.data, groups)
      result = {:collection => [], :mode => Tarsier.mode}
      groups.each_with_index do |group, index|
        chunk = {}
        if Tarsier.mode == :line
          chunk[:line] = Tarsier.arguments[:line_number]
          chunk[:file] = Tarsier.arguments[:file]
        else
          chunk[:files] = grouped_lines[index].map do |file, lines|
            { :name => file,
              :code => lines.sort.map {|line| "#{line + 1}: #{Tarsier.code_lines[file][line]}"}
            }
          end
        end
        chunk[:test_groups] = group
        result[:collection] << chunk
      end
      Tarsier.result.data = result
      directory = Tarsier.arguments[:output]
      if directory
        report_to_html(directory)
      else
        report_to_stdout
      end
    end

    private
      def self.report_to_html(directory)
        Dir::mkdir(directory) unless FileTest::directory?(directory)
        File.open("#{directory}/index.html", "w") do |f|
          template_string = File.open(
            File.expand_path("../template/index.html.erb", File.dirname(__FILE__)), 'r:UTF-8'
          ).read
          template = ERB.new(template_string, 0, "%<>")
          f.write template.result(Tarsier.result.get_binding)
        end

        %w(css js).each do |dir|
          FileUtils.cp_r "lib/template/#{dir}", directory
        end
      end

      def self.report_to_stdout
        result = Tarsier.result.data
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

      def self.condition(test_cases, file, line_number)
        if Tarsier.mode == :line
          file == File.expand_path(Tarsier.arguments[:file]) && (line_number + 1) == Tarsier.arguments[:line_number].to_i
        else
          test_cases.length > 1
        end
      end

      def self.test_case_groups(data)
        groups = []
        Tarsier.data.each do |file, lines|
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
        Tarsier.data.each do |file, lines|
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
