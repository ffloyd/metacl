# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metacl/version'

Gem::Specification.new do |spec|
  spec.name          = "metacl"
  spec.version       = MetaCL::VERSION
  spec.authors       = ["Roman Kolesnev"]
  spec.email         = ["rvkolesnev@gmail.com"]
  spec.summary       = %q{DSL for prototyping computation apps}
  spec.description   = %q{DSL that generates C code for different computation platforms (pure C, OpenCL, Intel Phi)}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
