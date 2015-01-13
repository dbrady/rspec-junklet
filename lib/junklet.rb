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
            let(arg) { "#{name}-#{SecureRandom.uuid}" }
          end
        end
      end
    end
  end
end
