module Loris
  class Result
    attr_accessor :dupa

    def initialize
      @dupa = 'DUPA!'
    end

    def get_binding
      binding()
    end
  end
end
