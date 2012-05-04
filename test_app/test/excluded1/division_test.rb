require 'require_relative'
require_relative '../../app/calculator'
require 'test/unit'

class TestDivision < Test::Unit::TestCase
  def test_eval
    assert_equal 3.0, Calculations::Division.eval('6 / 2')
    assert_equal 4.0, Calculations::Division.eval('8/2')
  end
end