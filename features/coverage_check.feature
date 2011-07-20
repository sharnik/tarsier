Feature: Script

  Background:
    Given a file named "app/calculator.rb" with:
      """
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
      """
    And a file named "app/calculations/multiplication.rb" with:
      """
      module Calculations
        class Multiplication
          def self.eval(input)
            num1, num2 = input.split /\s*\*\s*/
            num1.to_f * num2.to_f
          end
        end
      end
      """
    And a file named "app/calculations/addition.rb" with:
      """
      module Calculations
        class Sum
          def self.eval(input)
            num1, num2 = input.split /\s*\+\s*/
            num1.to_f + num2.to_f
          end
        end
      end
      """
    And a file named "test/calculator_test.rb" with:
      """
      require 'require_relative'
      require_relative '../lib/calculator'
      require 'test/unit'
      require 'mocha'

      class TestCalculator < Test::Unit::TestCase
        def test_that_runs_internal_methods
          assert_equal 9.0, Calculator.process('3*3')
        end

        def test_that_stubs_stuff
          Calculations::Sum.expects(:eval).with('3+3').returns(6.0)
          assert_equal 6.0, Calculator.process('3+3')
        end
      end
      """
    And a file named "test/multiplication_test.rb" with:
      """
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
      """
    And a file named "test/addition_test.rb" with:
      """
      require 'require_relative'
      require_relative '../lib/calculator'
      require 'test/unit'

      class TestSum < Test::Unit::TestCase
        def test_eval
          assert_equal 6.0, Calculations::Sum.eval('3 + 3')
          assert_equal 8.0, Calculations::Sum.eval('4+4')
        end
      end
      """

  Scenario: Looking for multicoverage
    When debug
    When I run `loris`
    Then the output should contain:
      """
      TestCalculator (test_that_runs_internal_methods), TestMultiplication (test_eval)
      """
    Then the output should contain:
      """
      /Users/krzysztof.herod/dev/rcov-thingy/test/../lib/calculations/multiplication.rb
      4:     def self.eval(input)
      5:       num1, num2 = input.split /\s*\*\s*/
      6:       num1.to_f * num2.to_f
      """

  Scenario: Looking for coverage of a line in a file
    When I run `loris app/calculations/multiplication.rb 4`
    Then the output should contain:
      """
      TestCalculator (test_that_runs_internal_methods), TestMultiplication (test_eval)
      """
