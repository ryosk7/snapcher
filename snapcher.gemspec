# frozen_string_literal: true

require_relative "lib/snapcher/version"

Gem::Specification.new do |spec|
  spec.name = "snapcher"
  spec.version = Snapcher::VERSION
  spec.authors = ["ryosk7"]
  spec.email = ["uchiryo7@gmail.com"]

  spec.summary = "Snapcher is an ORM extension that logs changes to specific columns to your model."
  spec.description = <<~EOF
    Snapcher is an ORM extension that logs changes to specific columns to your model.
    When a change is made to a specific column, the difference between before and after the change is obtained and saved.
    To make it easier for analysts, save the table name, column name, and data before and after changes as separate columns.
  EOF
  spec.homepage = "https://github.com/ryosk7/snapcher"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
