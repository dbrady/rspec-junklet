require "junklet/version"

module RSpec
  module Core
    module MemoizedHelpers
      module ClassMethods
        def junklet(*args)
          opts = args.size > 1 && !args.last.is_a?(Symbol) && args.pop || {}

          names = args.map(&:to_s)
          
          if opts.key?(:separator)
            names = names.map {|name| name.gsub(/_/, opts[:separator]) }
          end
          
          args.zip(names).each do |arg, name|
            let(arg) { "#{name}-#{junk}" }
          end
        end
      end

      def junk(size=32)
        trash = ""
        trash += SecureRandom.hex while trash.size < size
        trash = trash[0...size]
      end
    end

    # class ExampleGroup
    #   def self.junk
    #     SecureRandom.hex
    #   end
    # end
  end
end
