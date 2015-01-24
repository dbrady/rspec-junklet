# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'junklet/version'

Gem::Specification.new do |spec|
  spec.name          = "junklet"
  spec.version       = Junklet::VERSION
  spec.authors       = ["Dave Brady"]
  spec.email         = ["dbrady@covermymeds.com"]
  spec.summary       = "Easily create junk data for specs"
  spec.description   = "Works like let for rspec, but creates unique random junk data"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 2.0"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "pry"
end
