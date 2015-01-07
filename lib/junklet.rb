require "junklet/version"

module RSpec
  module Core
    module MemoizedHelpers
      module ClassMethods
        def junklet(*args)
          Array(args).each do |name|
            let(name) { "#{name}-#{SecureRandom.uuid}" }
          end
        end
      end
    end
  end
end
