require_relative "lib/google_maps_service/version"

Gem::Specification.new do |spec|
  spec.name = "google_maps_service"
  spec.version = GoogleMapsService::VERSION
  spec.authors = ["Lang Sharpe"]
  spec.email = ["langer8191@gmail.com"]

  spec.summary = "Ruby gem for Google Maps Web Service APIs"
  spec.homepage = "https://github.com/langsharpe/google-maps-services-ruby"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/langsharpe/google-maps-services-ruby/issues",
    "changelog_uri" => "https://raw.githubusercontent.com/langsharpe/google-maps-services-ruby/master/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/google_maps_service",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage
  }

  spec.files = Dir["LICENSE", "*.md", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "multi_json", "~> 1.15"
  spec.add_runtime_dependency "retriable", "~> 3.1"

  spec.add_development_dependency "coveralls_reborn", "~> 0.25.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "redcarpet", "~> 3.5.1"
  spec.add_development_dependency "rspec", "~> 3.11"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "standard", "~> 1.16"
  spec.add_development_dependency "webmock", "~> 3.18.1"
  spec.add_development_dependency "yard", "~> 0.9.28"
end
