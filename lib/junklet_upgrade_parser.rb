# What it does: 
# Find blocks of mixed lets and "junklets", a special DSL term we use here for
# junk data. It then rewrites the block so that the lets come first in
# original order, then a newline, then the junklets in order. So it turns this
# code:
#
# let(:name) { "Bob" }
# junklet :address
# let(:city) { "Faketown" }
# junklet :state
# junklet :zip
# let(:extra) { true }
# let(:pants) { ON_FIRE }
#
# Into THIS code, leaving the rest of the file unaltered:
#
# let(:name) { "Bob" }
# let(:city) { "Faketown" }
# let(:extra) { true }
# let(:pants) { ON_FIRE }
#
# junklet :address
# junklet :state
# junklet :zip
#

require_relative 'line'

# As with all parsers, this is easy if we allow peeking.
class JunkletUpgradeParser
  attr_reader :lines, :lets, :junklets, :mode, :current_line

  INACTIVE = 'inactive'
  MAYBE_ACTIVE = 'maybe_active'
  ACTIVE = 'active'
  
  def initialize
  end

  def inactive; INACTIVE; end
  def maybe_active; MAYBE_ACTIVE; end
  def active; ACTIVE; end

  def inactive?; mode == inactive; end
  def maybe_active?; mode == maybe_active; end
  def active?; mode == active; end

  def upgraded_lines(lines)
    @lines = lines
    return unless junky?
    we_are_inactive!
    emitted_lines = []
    lines.each do |line|
      self.current_line = imblart_line(line)
      case mode
      when inactive
        if current_line.let?
          lets << current_line
          we_are_maybe_active!
        elsif current_line.junklet?
          junklets << current_line
          we_are_active!
        elsif current_line.code?
          emitted_lines << current_line
        end
      when maybe_active
        if current_line.let?
          lets << current_line
        elsif current_line.junklet?
          junklets << current_line
          we_are_active!
        elsif current_line.code?
          emitted_lines += lets 
          emitted_lines << current_line
          we_are_inactive!
        end
      when active
        if current_line.let?
          lets << current_line
        elsif current_line.junklet?
          junklets << current_line
        elsif current_line.code?
          emitted_lines += reordered_block
          emitted_lines << current_line
          reset
          we_are_inactive!
        end
      end
    end

    # if lets || junklets we've hit EOF while active
    emitted_lines += reordered_block if active?
    emitted_lines
  end
  
  def reordered_block
    lets << "\n" unless lets.empty? || lets.last == "\n" || junklets.empty?
    lets + sort_junklets
  end

  def sort_junklets
    return if junklets.empty?
    indent = junklets.first.indent
    ["#{indent}junklet #{(junklets.map(&:names).sort * ', ')}\n"]
  end
  
  def imblart_line(line)
    Line.new line
  end

  def we_are_inactive!
    reset
    @mode = INACTIVE
  end

  def we_are_maybe_active!
    @mode = MAYBE_ACTIVE
  end

  def we_are_active!
    @mode = ACTIVE
  end

  def reset
    @lets, @junklets = [], []
  end

  def junky?
    lines.any? { |line| junk_line? line }
  end

  def junk_line?(line)
    line =~ /\bSecureRandom\./ || line =~ /\bjunklet\b/
  end

  private

  attr_accessor :current_line
end
