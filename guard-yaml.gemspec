# guard-yaml.gemspec
# frozen_string_literal: true

require_relative "lib/guard/yaml/version"

Gem::Specification.new do |gem|
  gem.name          = "guard-yaml"
  gem.version       = Guard::YamlVersion::VERSION
  gem.authors       = ["Phillip Ridlen", "Stan Carver II"]
  gem.email         = ["phillip@ovenbits.com", "howdy@stancarver.com"]
  gem.summary       = "Checks YAML syntax when watched files change"
  gem.description   = "A focused Guard plugin that parses watched YAML files and reports syntax errors."
  gem.homepage      = "https://github.com/philtr/guard-yaml#readme"
  gem.license       = "MIT"
  gem.required_ruby_version = ">= 3.1"

  gem.metadata = {
    "bug_tracker_uri" => "https://github.com/philtr/guard-yaml/issues",
    "changelog_uri" => "https://github.com/philtr/guard-yaml/blob/master/CHANGELOG.md",
    "homepage_uri" => gem.homepage,
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/philtr/guard-yaml"
  }

  gem.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |file| file.start_with?(".", "spec/") }
  end
  gem.require_paths = ["lib"]

  gem.add_dependency "guard", ">= 2.18", "< 3"

  gem.add_development_dependency "rake", "~> 13.2"
end
