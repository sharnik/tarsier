Feature: Script

  Background:
    Given a file named "app/calculator.rb" with:
      """
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
    And a file named "app/calculations/sum.rb" with:
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
    And a file named "test/calculations/division.rb" with:
      """
      module Calculations
        class Division
          def self.eval(input)
            num1, num2 = input.split /\s*\+\s*/
            num1.to_f / num2.to_f
          end
        end
      end
      """
    And a file named "test/calculations/sub.rb" with:
      """
      module Calculations
        class Sub
          def self.eval(input)
            num1, num2 = input.split /\s*\+\s*/
            num1.to_f - num2.to_f
          end
        end
      end
      """
    And a file named "test/calculator_test.rb" with:
      """
      require 'require_relative'
      require_relative '../app/calculator'
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
      require_relative '../app/calculator'
      require 'test/unit'
      require 'mocha'

      class TestMultiplication < Test::Unit::TestCase
        def test_eval
          assert_equal 9.0, Calculations::Multiplication.eval('3 * 3')
          assert_equal 16.0, Calculations::Multiplication.eval('4*4')
        end
      end
      """
    And a file named "test/sum_test.rb" with:
      """
      require 'require_relative'
      require_relative '../app/calculator'
      require 'test/unit'

      class TestSum < Test::Unit::TestCase
        def test_eval
          assert_equal 6.0, Calculations::Sum.eval('3 + 3')
          assert_equal 8.0, Calculations::Sum.eval('4+4')
        end
      end
      """
    And a file named "test/excluded1/division_test.rb" with:
      """
      require 'require_relative'
      require_relative '../../app/calculator'
      require 'test/unit'

      class TestDivision < Test::Unit::TestCase
        def test_eval
          assert_equal 3.0, Calculations::Division.eval('6 / 2')
          assert_equal 4.0, Calculations::Division.eval('8/2')
        end
      end
      """
    And a file named "test/excluded2/sub_test.rb" with:
      """
      require 'require_relative'
      require_relative '../../app/calculator'
      require 'test/unit'

      class TestSub < Test::Unit::TestCase
        def test_eval
          assert_equal 4.0, Calculations::Sub.eval('6 - 2')
          assert_equal 6.0, Calculations::Sub.eval('8-2')
        end
      end
      """

  Scenario: Looking for multicoverage
    When I run `rake loris:run tests_path=tmp/aruba/test`
    Then the output should contain:
      """
      TestCalculator (test_that_runs_internal_methods), TestMultiplication (test_eval)
      """
    Then the output should contain:
      """
      app/calculations/multiplication.rb
      3:     def self.eval(input)
      4:       num1, num2 = input.split /\s*\*\s*/
      5:       num1.to_f * num2.to_f
      """

  Scenario: Looking for coverage of a line in a file
    When I run `rake loris:run tests_path=tmp/aruba/test file=tmp/aruba/app/calculations/sum.rb line_number=3`
    Then the output should contain "TestSum (test_eval)"
    And the output should not contain "TestCalculator"
    And the output should not contain "TestMultiplication"

  Scenario: Looking for multicoverage excluding some directories
    When I run `rake loris:run tests_path=tmp/aruba/test exclude_path=tmp/aruba/test/excluded1,tmp/aruba/test/excluded2`
    Then the output should not contain "TestDivision (test_eval)"
    Then the output should not contain "TestSub (test_eval)"
    And the output should contain "TestCalculator"
    And the output should contain "TestMultiplication"