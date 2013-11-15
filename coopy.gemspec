# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coopy/version'

Gem::Specification.new do |spec|
  spec.name          = "coopy"
  spec.version       = Coopy::VERSION
  spec.authors       = ["James Smith"]
  spec.email         = ["james@floppy.org.uk"]
  spec.description   = %q{Ruby port of coopyhx, for calculating tabular diffs}
  spec.summary       = %q{Ruby port of coopyhx, for calculating tabular diffs}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov-rcov"
  spec.add_development_dependency "pry"
end
