require_relative 'junklet_type_error'

module RSpec
  module Junklet
    class Registry
      @@generators = {}

      def self.[] name
        @@generators[name]
      end

      def self.[]= name, generator
        raise JunkletTypeError.new("Junk type '#{name}' has already been registered") if @@generators[name]
        @@generators[name] = generator
      end

      def self.delete name
        @@generators.delete name
      end
    end
  end
end
