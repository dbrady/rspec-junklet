require "junklet/version"

module Junklet
  # Your code goes here...
end

module RSpec
  module Core
    module MemoizedHelpers
      module ClassMethods
        def junk_let(name)
          let(name) { "#{name}-#{SecureRandom.uuid}" }
        end
      end
    end
  end
end
