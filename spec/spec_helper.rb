SPEC_DIR = __dir__
ROOT_DIR = File.expand_path(File.join(SPEC_DIR, ".."))
LIB_DIR = File.expand_path(File.join(ROOT_DIR, "lib"))
FIXTURES_DIR = File.expand_path(File.join(SPEC_DIR, "fixtures"))

$LOAD_PATH.unshift(SPEC_DIR)
$LOAD_PATH.unshift(LIB_DIR)
$LOAD_PATH.uniq!

if defined?(JRUBY_VERSION)
  puts "Skipping coverage on JRuby"
else
  # set up coverage
  require "simplecov"
  require "coveralls"

  SimpleCov.formatters = [
    Coveralls::SimpleCov::Formatter,
    SimpleCov::Formatter::HTMLFormatter
  ]
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "version.rb"
  end
end

require "rspec"
require "webmock/rspec"
require "google_maps_service"

RSpec.shared_context "HTTP client" do
  let(:api_key) do
    "AIZa1234567890"
  end

  let(:client) do
    GoogleMapsService::Client.new(key: api_key)
  end
end
