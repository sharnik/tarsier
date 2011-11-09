# Loads monkeypatching of different test example classes.
# Currenty supports:
#   * Test::Unit::TestCase
#   * RSpec::Core::Example
#   * ActiveSupport::Testing::SetupAndTeardown::ForClassicTestUnit
#

if defined?(ActiveSupport::Testing::SetupAndTeardown::ForClassicTestUnit)
  puts 'Loads ActiveSupport monkeypatching.'
  module ActiveSupport
    module Testing
      module SetupAndTeardown
        module ForClassicTestUnit
          alias :run_without_analyzer :run
          def run(*args, &block)
            Loris.test_method_wrapper(self) do
              run_without_analyzer(*args, &block)
            end
          end
        end
      end
    end
  end
end

if defined?(::Test::Unit)
  module Test::Unit

    if defined?(::Test::Unit::AutoRunner)
      puts 'Loads Test::Unit::AutoRunner monkeypatching.'
      class AutoRunner
        alias :run_without_analyzer :run
        def run
          Loris.test_suite_wrapper do
            run_without_analyzer
          end
        end
      end
    end
    
    if defined?(::Test::Unit::TestCase)
      puts 'Loads Test::Unit::TestCase monkeypatching.'
      class TestCase
        alias :run_without_analyzer :run
        def run(*args, &block)
          Loris.test_method_wrapper(self) do
            run_without_analyzer(*args, &block)
          end
        end
      end
    end
  end
end

if defined?(::RSpec::Core::Example)
  puts 'Loads RSpec::Core::Example monkeypatching.'
  module ::RSpec::Core
    class Example
      alias :run_without_analyzer :run
      def run(*args, &block)
        Loris.test_method_wrapper(self) do
          run_without_analyzer(*args, &block)
        end
      end
    end
  end
end
