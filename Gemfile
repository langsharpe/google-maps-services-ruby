source 'https://rubygems.org'

# Specify your gem's dependencies in google_maps_service.gemspec
gemspec

group :development do
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.11'
  gem 'simplecov', '~> 0.21'
  gem 'coveralls_reborn', '~> 0.25.0', require: false
  gem 'webmock', '~> 3.18.1'
end

platforms :ruby do
  group :development do
    gem 'yard', '~> 0.9.28'
    gem 'redcarpet', '~> 3.5.1'
  end
end

if ENV['RAILS_VERSION']
  gem 'rails', ENV['RAILS_VERSION']
end
