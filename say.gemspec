# frozen_string_literal: true

require_relative "lib/say/version"

Gem::Specification.new do |spec|
  spec.name = "say"
  spec.version = Say::VERSION
  spec.authors = ["Paul DobbinSchmaltz"]
  spec.email = ["p.dobbinschmaltz@icloud.com"]

  spec.summary = "Say provides logging in the style of ActiveRecord::Migration#say... anywhere!"
  spec.description = "Say gives you the API and the output style you already know and love from ActiveRecord::Migration#say... anywhere! Plus a few extra goodies for long-running processes like incremental progress indicators and remaining time estimation."
  spec.homepage = "https://github.com/pdobb/say"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/pdobb/say/issues",
    "changelog_uri" => "https://github.com/pdobb/say/releases",
    "source_code_uri" => "https://github.com/pdobb/say",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true",
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_development_dependency "amazing_print"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "gemwork"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "timecop"
end
