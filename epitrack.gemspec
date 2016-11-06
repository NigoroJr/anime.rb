# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epitrack/version'

Gem::Specification.new do |spec|
  spec.name          = "epitrack"
  spec.version       = Epitrack::VERSION
  spec.authors       = ["Naoki Mizuno"]
  spec.email         = ["nigorojr@gmail.com"]

  spec.summary       = %q{Keep track of your episodes.}
  spec.description   = %q{A utility script to keep track of which episode of a series you have watched so far.}
  spec.homepage      = "https://github.com/NigoroJr/epitrack"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "unicode-display_width"
  spec.add_runtime_dependency "levenshtein"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
