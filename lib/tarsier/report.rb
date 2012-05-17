module Tarsier
  # Takes care of presenting the analysis results.
  class Report
    attr_accessor :attributes

    # Displays the report on STDOUT.
    #
    # @param [Hash] options for output
    # @return nil
    def self.puke_out_report
      Tarsier.result.compile_data
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

  end
end
