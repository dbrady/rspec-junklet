# spec_helper.rb

PROJECT_ROOT=Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), '..')))

require_relative PROJECT_ROOT + "lib" + "rspec" + "junklet"


require "pry"
require "byebug"

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

# be_in - working inverse of #cover and #include, e.g.
#
# let(:range) { (1..5) }
# let(:list) { [1,2,3,4,5] }
# let(:val) { 3 }
#
# specify { expect(range).to cover val }
# specify { expect(val).to be_in range }
# specify { expect(list).to include val }
# specify { expect(val).to be_in list }
#
# Why? Because sometimes I think reading order is important. For example, if the
# options for a command can vary and we want to assert that they contain a known
# correct value, I prefer
#
# specify { expect(options).to include value }
#
# As it is the options that are in question here. But if the list of known
# options is fixed, and the code under test returns a value that we want to
# prove is inside the list of known options, I prefer
#
# specify { expect(value).to be_in options }
#
# ...and yes, I frequently put an #in? method on Object that takes a collection,
# and simply calls collection.include?(self) internally. Again just because
# reading order.
RSpec::Matchers.define :be_in do |list|
  match do |element|
    list.include? element
  end
end
