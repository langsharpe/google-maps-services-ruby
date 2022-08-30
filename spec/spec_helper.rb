require "coveralls"
require "rspec"
require "simplecov"
require "webmock/rspec"

SimpleCov.formatters = [
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start do
  add_filter "/spec/"
end

require "google_maps_service"

RSpec.shared_context "HTTP client" do
  let(:api_key) do
    "AIZa1234567890"
  end

  let(:client) do
    GoogleMapsService::Client.new(key: api_key)
  end
end
