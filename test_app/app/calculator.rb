require 'require_relative'
require_relative 'calculations/multiplication'
require_relative 'calculations/sum'
class Calculator
  def self.process(input)
    input.strip!
    raise 'Unparseable expression.' unless input =~ /\A\d+\.*\d*\s*[\*+-\/]\s*\d+\.*\d*\z/
    if input =~ /\*/
      Calculations::Multiplication.eval(input)
    elsif input =~ /\+/
      Calculations::Sum.eval(input)
    else
      puts "Didn't find anything worth doing."
    end
  end
end