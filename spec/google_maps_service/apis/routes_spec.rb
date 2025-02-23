require "spec_helper"

describe GoogleMapsService::Apis::Routes do
  include_context "HTTP client"

  describe "#compute_route_matrix" do
    before(:example) do
      stub_request(:post, "https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix?key=%s" % api_key)
        .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: '{"status":"OK","rows":[]}')
    end

    context "basic params" do
      it "should call Google Maps Web Service" do
        origins = [{waypoint: {address: "South Brisbane, QLD, AU"}}]
        destinations = [{waypoint: {address: "Fitzroy, VIC, AU"}}, {waypoint: {address: "Richmond, VIC, AU"}}]
        expected_body = MultiJson.dump({
          origins: origins,
          destinations: destinations
        })

        client.compute_route_matrix(origins, destinations)
        expect(a_request(:post,
          "https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix?key=%s" % api_key)
          .with(body: expected_body))
          .to have_been_made
      end
    end
  end

  describe "#compute_routes" do
    before(:example) do
      stub_request(:post, "https://routes.googleapis.com/directions/v2:computeRoutes?key=%s" % api_key)
        .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: '{"status":"OK","rows":[]}')
    end

    context "basic params" do
      it "should call Google Maps Web Service" do
        origin = {address: "South Brisbane, QLD, AU"}
        destination = {address: "Fitzroy, VIC, AU"}
        expected_body = MultiJson.dump({
          origin: origin,
          destination: destination
        })

        client.compute_routes(origin, destination)
        expect(a_request(:post,
          "https://routes.googleapis.com/directions/v2:computeRoutes?key=%s" % api_key)
          .with(body: expected_body))
          .to have_been_made
      end
    end
  end
end
