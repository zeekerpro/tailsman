# frozen_string_literal: true

require_relative "lib/tailsman/version"

Gem::Specification.new do |spec|
  spec.name = "tailsman"
  spec.version = Tailsman::VERSION
  spec.authors = ["zeeker"]
  spec.email = ["zeekerpro@gmail.com"]

  spec.summary = "Tailsman is a lightweight and flexible Ruby on Rails gem that provides easy-to-use JWT-based authorization for your Rails applications. "
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/zeekerpro/tailsman"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/zeekerpro/tailsman"
  spec.metadata["changelog_uri"] = "https://github.com/zeekerpro/tailsman/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # dependencies: ruby-jwt, activesupport
  spec.add_dependency "jwt"
  spec.add_dependency "activesupport"

  # add development dependencies: rspec, rake, bundler
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "bundler"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
