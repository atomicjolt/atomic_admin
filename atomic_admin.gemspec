require_relative "lib/atomic_admin/version"

Gem::Specification.new do |spec|
  spec.name        = "atomic_admin"
  spec.version     = AtomicAdmin::VERSION
  spec.authors     = ["Nick Benoit"]
  spec.email       = ["nick.benoit@atomicjolt.com"]
  spec.homepage    = "https://github.com/atomicjolt/atomic_admin/"
  spec.summary     = "Engine to provide apis that power the atomic jolt admin app"
  spec.description = "Engine to provide apis that power the atomic jolt admin app"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/atomicjolt/atomic_admin/"
  spec.metadata["changelog_uri"] = "https://github.com/atomicjolt/atomic_admin/"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 7.0"
end
