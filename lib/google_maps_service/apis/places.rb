module GoogleMapsService::Apis
  module Places
    # Performs a nearby search using the Google Places API.
    #
    # @example Simple nearby search
    #   client.nearby_search([37.422,-122.084], 500)
    #
    # @example Complex nearby search
    #   client.nearby_search([37.422,-122.084], 500, keyword: "restaurant", language: "en", min_price: 3, max_price: 4, open_now: true, type: "restaurant")
    #
    # @example Rank by distance with keyword
    #   client.nearby_search([37.422,-122.084], 500, rank_by_distance: true, keyword: "restaurant")
    #
    # @param location [Hash, Array] The latitude/longitude around which to retrieve place information.
    #                                 This must be specified as a hash containing the keys :lat/:latitude, :lng/:longitude or an array pair of numbers
    # @param radius [Integer] The distance (in meters) within which to return place results.
    # @param keyword [String, nil] A term to be matched against all available fields, including but not limited to name, type, and address.
    # @param language [String, nil] The language code, indicating in which language the results should be returned.
    # @param min_price [Integer, nil] The minimum price level of the results, on a scale of 0 to 4.
    # @param max_price [Integer, nil] The maximum price level of the results, on a scale of 0 to 4.
    # @param name [String, nil] (Deprecated) A term to be matched against the names of places.
    # @param open_now [Boolean] Whether to return only those places that are open for business at the time the query is sent.
    # @param rank_by_distance [Boolean] Whether to order the results by distance from the specified location.
    #                                   If true, at least one of keyword, name, or type must be supplied.
    #                                   If false, rank by prominence is used.
    #                                   Note: If rank_by_distance is true, then radius is ignored.
    # @param type [String, nil] The type of place to be searched.
    # @param page_token [String, nil] A token used to return additional results beyond the maximum number of results available in a single request.
    # @return [Hash] A hash containing the response from the Google Maps API. See https://developers.google.com/places/web-service/search#PlaceSearchResponses
    # @raise [ArgumentError] If rank_by_distance is true and all of keyword, name, and type are nil.
    #
    def nearby_search(location, radius, keyword: nil, language: nil, min_price: nil,
                     max_price: nil, name: nil, open_now: false, rank_by_distance: false, type: nil, page_token: nil)

      params = {
        location: GoogleMapsService::Convert.latlng(location),
        radius: radius
      }

      params[:keyword] = keyword if keyword
      params[:language] = language if language
      params[:minprice] = min_price if min_price
      params[:maxprice] = max_price if max_price
      params[:name] = name if name
      params[:opennow] = "true" if open_now
      params[:rankby] = "distance" if rank_by_distance
      params[:type] = type if type
      params[:pagetoken] = page_token if page_token

      if rank_by_distance
        if keyword.nil? && name.nil? && type.nil?
          raise ArgumentError, "Must supply keyword, name, or type for rank_by=distance"
        end
        params.delete(:radius)
      end

      get("/maps/api/place/nearbysearch/json", params)
    end
  end
end
