require 'require_relative'
require_relative '../lib/calculator'
require 'test/unit'
require 'mocha'

class TestMultiplication < Test::Unit::TestCase
  def test_eval
    assert_equal 9.0, Calculations::Multiplication.eval('3 * 3')
    assert_equal 16.0, Calculations::Multiplication.eval('4*4')
  end
end


