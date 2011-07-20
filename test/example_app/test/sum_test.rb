require 'require_relative'
require_relative '../lib/calculator'
require 'test/unit'

class TestSum < Test::Unit::TestCase
  def test_eval
    assert_equal 6.0, Calculations::Sum.eval('3 + 3')
    assert_equal 8.0, Calculations::Sum.eval('4+4')
  end
end



