require 'require_relative'
require_relative '../../app/calculator'
require 'test/unit'

class TestSub < Test::Unit::TestCase
  def test_eval
    assert_equal 4.0, Calculations::Sub.eval('6 - 2')
    assert_equal 6.0, Calculations::Sub.eval('8-2')
  end
end