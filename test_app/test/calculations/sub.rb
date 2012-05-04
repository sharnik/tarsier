module Calculations
  class Sub
    def self.eval(input)
      num1, num2 = input.split /\s*\-\s*/
      num1.to_f - num2.to_f
    end
  end
end