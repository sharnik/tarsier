module Loris

  # Holds analyzer data from rcov analyzers for all code files.
  @@data = {}
  def self.data
    @@data
  end

  # Holds actual code lines of code that has been run.
  @@code_lines = {}
  def self.code_lines
    @@code_lines
  end

end
