# spec_helper.rb

PROJECT_ROOT=Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), '..')))

require_relative PROJECT_ROOT + "lib" + "rspec" + "junklet"


require "pry"

# Since we've kept rigidly to 80-columns, we can easily
# Do a pretty side-by-side diff here. This won't handle
# Line deletions/insertions but for same/same diffs it'll
# work fine.
ESC = 27.chr
GREEN = "%c[%sm" % [ESC, 32]
RED = "%c[%sm" % [ESC, 31]
RESET = "%c[0m" % ESC

def dump_hline
  puts(("-" * 80) + "-+-" + ("-" * 80))
end

def dump_captions
  puts "%-80s | %s" % ["EXPECTED", "GOT"]
end

def dump_header
  dump_hline
  dump_captions
end

def dump_footer
  dump_hline
end

def line_pairs(expected_lines, got_lines)
  expected_lines.zip(got_lines).map { |words| words.map {|w| w ? w.rstrip : "" } }
end

def dump_diff(expected_lines, got_lines)
  dump_header

  line_pairs(expected_lines, got_lines).each do |a,b|
    color_code = a == b ? GREEN : RED
    puts "#{color_code}%-80s | %s#{RESET}" % [a,b]
  end
  dump_footer
end
