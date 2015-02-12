require "junklet/version"
require "junklet/junk"
require "junklet/junklet"

RSpec.configure do |config|
  config.extend(Junklet::Junklet)
  config.include(Junklet::Junk)
end
