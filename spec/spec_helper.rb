# spec_helper.rb

require_relative '../lib/junklet'

require 'pry'

# Since we've kept rigidly to 80-columns, we can easily
# Do a pretty side-by-side diff here. This won't handle
# Line deletions/insertions but for same/same diffs it'll
# work fine.
ESC = 27.chr
GREEN = "%c[%sm" % [ESC, 32]
RED = "%c[%sm" % [ESC, 31]
RESET = "%c[0m" % ESC

def dump_diff(expected_lines, got_lines)
  puts(('-' * 80) + '-+-' + ('-' * 80))
  puts '%-80s | %s' % ["EXPECTED", "GOT"]
  if got_lines.size > expected_lines.size
    expected_lines += Array.new(got_lines.size-expected_lines.size, '')
  end
  expected_lines.zip(got_lines).each do |a,b|
    color_code = a == b ? GREEN : RED
    puts "#{RED}%-80s | %s#{RESET}" % [color_code,a.rstrip,b.rstrip]
  end
  puts(('-' * 80) + '-+-' + ('-' * 80))
end

