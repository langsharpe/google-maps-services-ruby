module GoogleMapsService::Apis
  # Performs requests to the Google Maps Routes API.
  module Routes
    # Base URL of Google Maps Routes API
    ROUTES_BASE_URL = "https://routes.googleapis.com"

    # Compute a route matrix
    #
    # Only origins and destinations are required. The formats for each of the paramters are defined at
    # https://developers.google.com/maps/documentation/routes/reference/rest/v2/TopLevel/computeRouteMatrix
    #
    # @example Simple route matrix
    # matrix = gmaps.compute_route_matrix(
    #   [
    #     {waypoint: {address: 'South Brisbane, QLD, AU'}}
    #   ],
    #   [
    #     {waypoint: {address: 'Fitzroy, VIC, AU'}},
    #     {waypoint: {address: 'Richmond, VIC, AU'}}
    #   ],
    # )
    #
    # @example Complex route matrix
    # matrix = gmaps.compute_route_matrix(
    #   [{waypoint: {address: 'South Brisbane, QLD, AU'}}],
    #   [{waypoint: {address: 'Fitzroy, VIC, AU'}},{waypoint: {address: 'Richmond, VIC, AU'}}],
    #   travel_mode: "TRANSIT",
    #   departure_time: Time.now,
    #   language_code: "en",
    #   region_code: "AU",
    #   units: "METRIC",
    #   extra_computations: ["TOLLS"],
    #   transit_preferences: {
    #     allowedTravelModes: [ "RAIL" ],
    #     routingPreference: "FEWER_TRANSFERS"
    #   }
    # )
    #
    # @param [Array] origins One or more RouteMatrixOrigin
    # @param [Array] destinations One or more RouteMatrixDestination
    # @param [String] field_mask The fields that should be returned in the response. The default is "*"
    # @param [String] travel_mode
    # @param [String] routing_preference
    # @param [String, Time] departure_time
    # @param [String, Time] arrival_time
    # @param [String] language_code
    # @param [String] region_code
    # @param [String] units
    # @param [Array] extra_computations
    # @param [String] traffic_model
    # @param [Hash] transit_preferences
    #
    def compute_route_matrix(origins, destinations,
      field_mask: nil,
      travel_mode: nil,
      routing_preference: nil,
      departure_time: nil,
      arrival_time: nil,
      language_code: nil,
      region_code: nil,
      units: nil,
      extra_computations: nil,
      traffic_model: nil,
      transit_preferences: nil)
      params = {
        origins: origins,
        destinations: destinations
      }

      params[:travelMode] = travel_mode if travel_mode
      params[:routingPreference] = routing_preference if routing_preference
      params[:departureTime] = time_convert(departure_time) if departure_time
      params[:arrivalTime] = time_convert(arrival_time) if arrival_time
      params[:languageCode] = language_code if language_code
      params[:regionCode] = region_code if region_code
      params[:units] = units if units
      params[:extraComputations] = extra_computations if extra_computations
      params[:trafficModel] = traffic_model if traffic_model
      params[:transitPreferences] = transit_preferences if transit_preferences

      field_mask ||= "*"

      post("/distanceMatrix/v2:computeRouteMatrix", params,
        base_url: ROUTES_BASE_URL,
        custom_response_decoder: method(:extract_routes_body),
        field_mask: field_mask)
    end

    # Compute routes between locations
    #
    # Returns the primary route along with optional alternate routes, given a set of terminal
    # and intermediate waypoints.
    #
    # Only the origin and destination is required. The formats for each of the paramters are defined at
    # https://developers.google.com/maps/documentation/routes/reference/rest/v2/TopLevel/computeRoutes
    #
    # @example Simple route request
    # route = gmaps.compute_routes(
    #   {address: 'South Brisbane, QLD, AU'},
    #   {address: 'Fitzroy, VIC, AU'}
    # )
    #
    # @example Complex route request with options
    # route = gmaps.compute_routes(
    #   {location: {latLng: {latitude: -27.4698, longitude: 153.0251}}},
    #   {address: 'Fitzroy, VIC, AU'},
    #   intermediates: [{address: 'Ultimo, NSW, AU'}],
    #   travel_mode: 'DRIVE',
    #   routing_preference: 'TRAFFIC_AWARE',
    #   departure_time: Time.now + 3600,
    #   language_code: 'en',
    #   region_code: 'AU',
    #   units: 'METRIC',
    #   extra_computations: ['TOLLS'],
    #   compute_alternative_routes: true
    # )
    #
    # @param [Hash] origin Required. Origin waypoint
    # @param [Hash] destination Required. Destination waypoint
    # @param [Array] intermediates
    # @param [String] travel_mode
    # @param [String] routing_preference
    # @param [String] polyline_quality
    # @param [String] polyline_encoding
    # @param [String, Time] departure_time
    # @param [String, Time] arrival_time
    # @param [Boolean] compute_alternative_routes
    # @param [Hash] route_modifiers
    # @param [String] language_code
    # @param [String] region_code
    # @param [String] units
    # @param [Boolean] optimize_waypoint_order
    # @param [Array] requested_reference_routes
    # @param [Array] extra_computations
    # @param [String] traffic_model
    # @param [Hash] transit_preferences
    # @param [String] field_mask
    #
    def compute_routes(origin, destination,
      intermediates: nil,
      travel_mode: nil,
      routing_preference: nil,
      polyline_quality: nil,
      polyline_encoding: nil,
      departure_time: nil,
      arrival_time: nil,
      compute_alternative_routes: nil,
      route_modifiers: nil,
      language_code: nil,
      region_code: nil,
      units: nil,
      optimize_waypoint_order: nil,
      requested_reference_routes: nil,
      extra_computations: nil,
      traffic_model: nil,
      transit_preferences: nil,
      field_mask: nil)
      params = {
        origin: origin,
        destination: destination
      }

      params[:intermediates] = intermediates if intermediates
      params[:travelMode] = travel_mode if travel_mode
      params[:routingPreference] = routing_preference if routing_preference
      params[:polylineQuality] = polyline_quality if polyline_quality
      params[:polylineEncoding] = polyline_encoding if polyline_encoding
      params[:departureTime] = time_convert(departure_time) if departure_time
      params[:arrivalTime] = time_convert(arrival_time) if arrival_time
      params[:computeAlternativeRoutes] = compute_alternative_routes unless compute_alternative_routes.nil?
      params[:routeModifiers] = route_modifiers if route_modifiers
      params[:languageCode] = language_code if language_code
      params[:regionCode] = region_code if region_code
      params[:units] = units if units
      params[:optimizeWaypointOrder] = optimize_waypoint_order unless optimize_waypoint_order.nil?
      params[:requestedReferenceRoutes] = requested_reference_routes if requested_reference_routes
      params[:extraComputations] = extra_computations if extra_computations
      params[:trafficModel] = traffic_model if traffic_model
      params[:transitPreferences] = transit_preferences if transit_preferences

      field_mask ||= "*"

      post("/directions/v2:computeRoutes", params,
        base_url: ROUTES_BASE_URL,
        custom_response_decoder: method(:extract_routes_body),
        field_mask: field_mask)
    end

    private

    # Extracts a result from a Routes API HTTP response.
    def extract_routes_body(response)
      begin
        body = MultiJson.load(response.body, symbolize_keys: true)
      rescue
        raise GoogleMapsService::Error::ApiError.new(response), "Received a malformed response."
      end

      if response.code == "400"
        message = body.is_a?(Array) ? body.first[:error][:message] : body[:error][:message]
        raise GoogleMapsService::Error::ClientError.new(response), message
      else
        check_response_status_code(response)
      end

      body
    end

    def time_convert(value)
      if value.is_a?(Time)
        value.utc.iso8601
      else
        value
      end
    end
  end
end
