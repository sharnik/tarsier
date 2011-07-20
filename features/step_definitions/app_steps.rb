When /debug/ do
  require "ruby-debug";Debugger.start;debugger;
end

When /show me the output/ do
  puts all_stdout
end
