require 'rspec'
require_relative "./junklet/version"
require_relative "./junklet/junk"
require_relative "./junklet/junklet"

# Automatically hook into RSpec when you `include "rspec-junklet"`
RSpec.configure do |config|
  config.extend(RSpec::Junklet::Junklet) # This lets us say junklet() in describes and contexts
  config.extend(RSpec::Junklet::Junk)    # This lets us say junk() in describes and contexts
  config.include(RSpec::Junklet::Junk)   # This lets us say junk() in lets
end
