require_relative '../lib/calculator'
require 'minitest/autorun'
require 'mocha'

class TestMultiplication < MiniTest::Unit::TestCase

  def test_eval
    assert_equal 9.0, Calculations::Multiplication.eval('3 * 3')
    assert_equal 16.0, Calculations::Multiplication.eval('4*4')
  end
end


