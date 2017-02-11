module RSpec
  module Junklet
    class Generator
      def initialize(options={})
      end

      def call
        fail "Generator#call() must be overidden by child class"
      end
    end
  end
end
