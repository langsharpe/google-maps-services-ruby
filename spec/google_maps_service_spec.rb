require "spec_helper"

describe GoogleMapsService do
  it "has a version number" do
    expect(GoogleMapsService::VERSION).not_to be nil
  end

  it "can detect os version" do
    expect(GoogleMapsService::OS_VERSION).not_to be nil
  end
end
