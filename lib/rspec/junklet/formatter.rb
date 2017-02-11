module RSpec
  module Junklet
    # Formatter.new(input) receives the generated junk, and #format returns the
    # input already formatted. You don't have to inherit from this class; as
    # long as your class accepts one argument to .new and responds to #format
    # you're a formatter. Inheriting from Formatter means you already have a
    # basic implementation, however.
    class Formatter
      attr_reader :input

      def initialize(input)
        @input = input
      end

      # You probably want to override this
      def format
        input
      end
    end
  end
end
