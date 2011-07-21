module Test
  module Unit
    class AutoRunner
      alias :run_without_analyzer :run
      def run
        Loris.test_case_wrapper do
          run_without_analyzer
        end
      end
    end
  end
end

module Test
  module Unit
    class TestCase
      alias :run_without_analyzer :run
      def run(*args, &block)
        Loris.test_suite_wrapper(self) do
          run_without_analyzer(*args, &block)
        end
      end
    end
  end
end

