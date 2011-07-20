module Loris
  # Holds analyzer data from rcov analyzers for all code files.
  accessor :data, {}
  # Holds actual code lines of code that has been run.
  accessor :code_lines, {}
  # Arguments with which the script is called
  accessor :arguments, {}

  def self.mode
    if arguments[:file] and arguments[:line_number]
      :find_files
    else
      :collect_tests
    end
  end
end
