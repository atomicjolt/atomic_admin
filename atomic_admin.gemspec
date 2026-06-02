require_relative "lib/atomic_admin/version"

Gem::Specification.new do |spec|
  spec.name        = "atomic_admin"
  spec.version     = AtomicAdmin::VERSION
  spec.authors     = ["Nick Benoit", "Sean Collings"]
  spec.email       = ["nick.benoit@atomicjolt.com", "sean.collings@atomicjolt.com"]
  spec.homepage    = "https://github.com/atomicjolt/atomic_admin/"
  spec.summary     = "Engine to provide apis that power the Atomic Jolt admin app"
  spec.description = "Engine to provide apis that power the Atomic Jolt admin app"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/atomicjolt/atomic_admin/"
  spec.metadata["changelog_uri"] = "https://github.com/atomicjolt/atomic_admin/"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0", "< 9.0"
  spec.add_dependency "atomic_lti", ">= 1.5.0", "< 2.0.0"
  spec.add_dependency "atomic_tenant", ">= 1.2.0", "< 2.0.0"
  spec.add_dependency "httparty", ">= 0.24.0", "< 1.0.0"
end
