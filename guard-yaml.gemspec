# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/yaml/version'

Gem::Specification.new do |gem|
  gem.name          = "guard-yaml"
  gem.version       = Guard::YamlVersion::VERSION
  gem.authors       = ["Phillip Ridlen"]
  gem.email         = ["phillip@ovenbits.com"]
  gem.description   = %q{Checks your YAML syntax. That's all.}
  gem.summary       = %q{You pass it a list of files to watch, it tries to parse them as YAML, and returns any errors that occurred while doing that.}
  gem.homepage      = "https://github.com/philtr/guard-yaml"

  gem.add_dependency "guard", ">= 1.1"
  gem.add_development_dependency "bundler", "~> 1.1"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
