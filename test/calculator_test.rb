require 'require_relative'

require_relative '../lib/calculator'
require 'minitest/unit'
# require 'minitest/autorun'
require 'mocha'

class TestCalculator < MiniTest::Unit::TestCase
  def test_that_runs_internal_methods
    assert_equal 9.0, Calculator.process('3*3')
  end

  def test_that_stubs_stuff
    Calculations::Sum.expects(:eval).with('3+3').returns(6.0)
    assert_equal 6.0, Calculator.process('3+3')
  end
end

