module Tarsier
  class Result
    attr_accessor :data

    def initialize
    end

    def get_binding
      binding()
    end
  end
end
