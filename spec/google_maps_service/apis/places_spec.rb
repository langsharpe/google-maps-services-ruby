describe GoogleMapsService::Apis::Places do
  include_context "HTTP client"

  before(:example) do
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/place\/nearbysearch\/.*/)
      .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: '{"status":"OK","results":[]}')
  end

  context "simple nearby search" do
    it "should call Google Maps Web Service" do
      client.nearby_search([37.422,-122.084], 500)
      expect(a_request(:get, "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.422000%%2C-122.084000&radius=500&key=%s" %
                          api_key)).to have_been_made
    end
  end

  context "complex request" do
    it "should call Google Maps Web Service" do
      client.nearby_search([37.422,-122.084], 500,
        keyword: "restaurant",
        language: "en",
        min_price: 1,
        max_price: 4,
        open_now: true,
        type: "restaurant")
      expect(a_request(:get, "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.422000%%2C-122.084000&radius=500&keyword=restaurant&language=en&minprice=1&maxprice=4&opennow=true&type=restaurant&key=%s" %
                          api_key)).to have_been_made
    end
  end

  context "rank by distance without keyword, name, or type" do
    it "should raise ArgumentError" do
      expect {
        client.nearby_search([37.422,-122.084], 500, rank_by_distance: true)
      }.to raise_error ArgumentError
    end
  end

  context "rank by distance with keyword" do
    it "should call Google Maps Web Service" do
      client.nearby_search([37.422,-122.084], 500,
        rank_by_distance: true,
        keyword: "restaurant")
      expect(a_request(:get, "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.422000%%2C-122.084000&keyword=restaurant&rankby=distance&key=%s" %
                          api_key)).to have_been_made
    end
  end

  context "rank by distance with name" do
    it "should call Google Maps Web Service" do
      client.nearby_search([37.422,-122.084], 500,
        rank_by_distance: true,
        name: "Cafe")
      expect(a_request(:get, "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.422000%%2C-122.084000&name=Cafe&rankby=distance&key=%s" %
                          api_key)).to have_been_made
    end
  end

  context "rank by distance with type" do
    it "should call Google Maps Web Service" do
      client.nearby_search([37.422,-122.084], 500,
        rank_by_distance: true,
        type: "point_of_interest")
      expect(a_request(:get, "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.422000%%2C-122.084000&type=point_of_interest&rankby=distance&key=%s" %
                          api_key)).to have_been_made
    end
  end
end
