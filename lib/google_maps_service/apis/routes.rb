module GoogleMapsService::Apis
  # Performs requests to the Google Maps Routes API.
  module Routes
    # Base URL of Google Maps Routes API
    ROUTES_BASE_URL = "https://routes.googleapis.com"

    # Compute a route matrix
    #
    # @param [Array] origins One or more RouteMatrixOrigin as defined at
    #        https://developers.google.com/maps/documentation/routes/route-matrix#route_matrix_origin
    # @param [Array] destinations One or more RouteMatrixDestination as defined at
    #       https://developers.google.com/maps/documentation/routes/route-matrix#route_matrix_destination
    def compute_route_matrix(origins, destinations)
      params = {
        origins: origins,
        destinations: destinations
      }
      post("/distanceMatrix/v2:computeRouteMatrix", params,
        base_url: ROUTES_BASE_URL,
        custom_response_decoder: method(:extract_routes_body),
        field_mask: "*")
    end

    private

    # Extracts a result from a Routes API HTTP response.
    def extract_routes_body(response)
      check_response_status_code(response)
      begin
        body = MultiJson.load(response.body, symbolize_keys: true)
      rescue
        raise GoogleMapsService::Error::ApiError.new(response), "Received a malformed response."
      end

      body
    end
  end
end
