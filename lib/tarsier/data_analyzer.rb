module Tarsier
  class DataAnalyzer
    attr_accessor :data

    def initialize
      @data = {}
    end

    def get_binding
      binding()
    end

    def compile_data
      groups = test_case_groups(Tarsier.data_collector.data)
      groups.sort! {|a, b| b.keys.length <=> a.keys.length }
      grouped_lines = data_grouped(Tarsier.data_collector.data, groups)
      result = {:collection => [], :mode => Tarsier.mode}
      groups.each_with_index do |group, index|
        chunk = {}
        if Tarsier.mode == :line
          chunk[:line] = Tarsier.arguments[:line_number]
          chunk[:file] = Tarsier.arguments[:file]
        else
          chunk[:files] = grouped_lines[index].map do |file, lines|
            { :name => file,
              :code => lines.sort.map {|line| "#{line + 1}: #{Tarsier.data_collector.code_lines[file][line]}"}
            }
          end
        end
        chunk[:test_groups] = group
        result[:collection] << chunk
      end
      @data = result
    end

    private

    def test_case_groups(data)
      groups = []
      Tarsier.data_collector.data.each do |file, lines|
        lines.each do |line_number, test_cases|
          if condition(test_cases, file, line_number)
            groups << test_cases unless groups.index(test_cases)
          end
        end
      end
      groups
    end

    def data_grouped(data, groups)
      grouped_lines = []
      Tarsier.data_collector.data.each do |file, lines|
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
  
    def condition(test_cases, file, line_number)
      if Tarsier.mode == :line
        file == File.expand_path(Tarsier.arguments[:file]) && (line_number + 1) == Tarsier.arguments[:line_number].to_i
      else
        test_cases.length > 1
      end
    end

  end
end
