require_relative "./junklet/version"
require_relative "./junklet/junk"
require_relative "./junklet/junklet"

RSpec.configure do |config|
  config.extend(RSpec::Junklet::Junklet)
  config.extend(RSpec::Junklet::Junk) # when metaprogramming cases, you may need junk in ExampleGroups
  config.include(RSpec::Junklet::Junk)
end
