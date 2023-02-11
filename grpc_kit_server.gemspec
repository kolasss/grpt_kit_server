# frozen_string_literal: true

require_relative "lib/grpc_kit_server/version"

Gem::Specification.new do |spec|
  spec.name = "grpc_kit_server"
  spec.version = GrpcKitServer::VERSION
  spec.authors = ["kolas"]
  spec.email = ["kolas.batman@gmail.com"]

  spec.summary = "Simple wrapper around gem grpc_kit"
  spec.description = "Simple wrapper around gem grpc_kit, implements part of interface of gem grpc"
  spec.homepage = "https://example.com"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "https://example.com"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "serverengine", "~> 2.3.1"
  spec.add_dependency 'grpc_kit', '~> 0.5.1'
  # spec.add_dependency 'async-io'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
