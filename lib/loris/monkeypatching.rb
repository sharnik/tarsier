if defined?(Test::Unit)
  puts 'Loads Test::Unit monkeypatching.'

  # Loads Test::Unit monkeypatching to run the rcov analyzer
  module Test::Unit
    class AutoRunner
      alias :run_without_analyzer :run
      def run
        Loris.test_suite_wrapper do
          run_without_analyzer
        end
      end
    end

    class TestCase
      alias :run_without_analyzer :run
      def run(*args, &block)
        Loris.test_method_wrapper(self) do
          run_without_analyzer(*args, &block)
        end
      end
    end
  end
else
  puts 'No Test::Unit testcases where loaded.'
end
