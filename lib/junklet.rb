require "junklet/version"
require "junklet/junk"
require "junklet/junklet"

RSpec.configure do |config|
  config.extend(Junklet::Junklet)
  config.extend(Junklet::Junk) # when metaprogramming cases, you may need junk in ExampleGroups
  config.include(Junklet::Junk)
end
