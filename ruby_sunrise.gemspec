# frozen_string_literal: true

$LOAD_PATH.append File.expand_path("lib", __dir__)
require "ruby_sunrise/identity"

Gem::Specification.new do |spec|
  spec.name = RubySunrise::Identity.name
  spec.version = RubySunrise::Identity.version
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Mike Reedell"]
  spec.email = ["mike@reedell.com"]
  spec.homepage = "http://www.mikereedell.com"
  spec.summary = "Calculate the sunrise/sunset given lat/long coordinates and the date.  Computes civil, official, nautical, and astronomical sunrise/sunset."
  spec.license = "MIT"

  spec.metadata = {
    "source_code_uri" => "https://github.com/bkuhlmann/ruby_sunrise",
    "changelog_uri" => "https://github.com/bkuhlmann/ruby_sunrise/blob/master/CHANGES.md",
    "bug_tracker_uri" => "https://github.com/bkuhlmann/ruby_sunrise/issues"
  }

  spec.required_ruby_version = "~> 2.6"
  spec.add_dependency "tzinfo", "~> 1.0"
  spec.add_development_dependency "gemsmith", "~> 13.4"
  spec.add_development_dependency "git-cop", "~> 3.0"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "pry", "~> 0.12"
  spec.add_development_dependency "pry-byebug", "~> 3.7"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.8"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.require_paths = ["lib"]
end
