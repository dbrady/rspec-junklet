module Junklet
  class Formatter
    attr_reader :input

    def initialize(input)
      @input = input
    end

    # You probably want to override this
    def value
      @input
    end

    # You probably want to override this
    def format
      value
    end
  end
end
