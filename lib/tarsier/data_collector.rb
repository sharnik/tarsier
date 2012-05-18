module Tarsier
  class DataCollector

    attr_accessor :code_lines
    attr_accessor :data

    def initialize
      @code_lines = {}
      @data = {}
    end

  end
end
