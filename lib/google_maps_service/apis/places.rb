require_relative '../validator'

module GoogleMapsService::Apis

  # Performs requests to the Google Maps Places API.
  module Places

    # Places search.
    #
    # @param [String] query The text string on which to search, for example: "restaurant".
    # @param [String, Hash, Array] location The latitude/longitude value for which you wish to obtain the
    #        closest, human-readable address.
    # @param [Integer] radius Distance in meters within which to bias results.
    # @param [String] language The language in which to return results.
    # @param [Integer] min_price Restricts results to only those places with no less than
    #        this price level. Valid values are in the range from 0 (most affordable)
    #        to 4 (most expensive).
    # @param [Integer] max_price Restricts results to only those places with no greater
    #        than this price level. Valid values are in the range from 0 (most
    #        affordable) to 4 (most expensive).
    # @param [Boolean] open_now Return only those places that are open for business at
    #         the time the query is sent.
    # @param [String] type Restricts the results to places matching the specified type.
    #        The full list of supported types is available here:
    #        https://developers.google.com/places/supported_types
    # @param [String] page_token Token from a previous search that when provided will
    #        returns the next page of results for the same search.
    # @return [Hash] Hash with the following keys:
    #         results: list of places
    #         html_attributions: set of attributions which must be displayed
    #         next_page_token: token for retrieving the next page of results
    def places(query, location: nil, radius: nil, language: nil, min_price: nil,
        max_price: nil, open_now: false, type: nil, page_token: nil)

      return _places("text", query: query, location: location, radius: radius,
            language: language, min_price: min_price, max_price: max_price,
            open_now: open_now, type: type, page_token: page_token)
    end

    # Performs nearby search for places.
    #
    # @param [String, Hash, Array] location The latitude/longitude value for
    #        which you wish to obtain the closest, human-readable address.
    # @param [Integer] radius Distance in meters within which to bias results.
    # @param [String] keyword A term to be matched against all content that
    #        Google has indexed for this place.
    # @param [String] language The language in which to return results.
    # @param [Integer] min_price Restricts results to only those places with no
    #        less than this price level. Valid values are in the range from 0
    #        (most affordable) to 4 (most expensive).
    # @param [Integer] max_price Restricts results to only those places with no
    #         greater than this price level. Valid values are in the range
    #         from 0 (most affordable) to 4 (most expensive).
    # @param [String, Array] name One or more terms to be matched against the
    #        names of places.
    # @param [Boolean] open_now Return only those places that are open for
    #         business at the time the query is sent.
    # @param [String] rank_by Specifies the order in which results are listed.
    #         Possible values are: prominence (default), distance
    # @param [String] type Restricts the results to places matching the
    #         specified type. The full list of supported types is available
    #         here: https://developers.google.com/places/supported_types
    # @param [String] page_token Token from a previous search that when provided
    #         will returns the next page of results for the same search.
    # @return [Hash] Hash with the following keys:
    #         status: status code
    #         results: list of places
    #         html_attributions: set of attributions which must be displayed
    #         next_page_token: token for retrieving the next page of results
    def places_nearby(location, radius: nil, keyword: nil, language: nil,
        min_price: nil, max_price: nil, name: nil, open_now: false,
        rank_by: nil, type: nil, page_token: nil)

        if rank_by == "distance"
          if !(keyword || name || type)
            raise ArgumentError, "either a keyword, name, or type arg is " +
              "required when rank_by is set to distance"
          elsif radius
            raise ArgumentError, "radius cannot be specified when rank_by " +
              "is set to distance"
          end
        end

      return _places("nearby", location: location, radius: radius,
                     keyword: keyword, language: language, min_price: min_price,
                     max_price: max_price, name: name, open_now: open_now,
                     rank_by: rank_by, type: type, page_token: page_token)      
    end


    # Performs radar search for places.
    #
    # @param[String, Hash, Array] location The latitude/longitude value for
    #        which you wish to obtain the closest, human-readable address.
    # @param [Integer] radius Distance in meters within which to bias results.
    # @param[String] keyword A term to be matched against all content that
    #        Google has indexed for this place.
    # @param[Integer] min_price Restricts results to only those places with no
    #        less than this price level. Valid values are in the range from 0
    #        (most affordable) to 4 (most expensive).
    # @param[Integer] max_price Restricts results to only those places with no
    #        greater than this price level. Valid values are in the range
    #        from 0 (most affordable) to 4 (most expensive).
    # @param[String, Array] name One or more terms to be matched against the
    #        names of places.
    # @param[Boolean] open_now Return only those places that are open for
    #        business at the time the query is sent.
    # @param[String] type Restricts the results to places matching the specified
    #       type. The full list of supported types is available here:
    #       https://developers.google.com/places/supported_types
    # @return[Hash] Hash with the following keys:
    #         status: status code
    #         results: list of places
    #         html_attributions: set of attributions which must be displayed
    def places_radar(location, radius, keyword: nil, min_price: nil,
        max_price: nil, name: nil, open_now: false, type: nil)

      if !(keyword || name || type)
        raise ArgumentError, "either a keyword, name, or type arg is required"
      end

      return _places("radar", location: location, radius: radius,
                     keyword: keyword, min_price: min_price, max_price: max_price,
                     name: name, open_now: open_now, type: type)
    end

    # Comprehensive details for an individual place.
    #
    # @param[String] place_id A textual identifier that uniquely identifies a
    #       place, returned from a Places search.
    # @param[String] language The language in which to return results.
    # @return[Hash] Hash with the following keys:
    #     result: dict containing place details
    #     html_attributions: set of attributions which must be displayed
    def place(place_id, language: nil)
      params = { placeid: place_id }
      params[:language] = language if language
      return get('/maps/api/place/details/json', params)
    end

    # Photo URL from the Places API.
    #
    # @param[String] photo_reference A string identifier that uniquely
    #       identifies a photo, as provided by either a Places search or Places
    #       detail request.
    # @param[Integer] max_width Specifies the maximum desired width, in pixels.
    # @param[Integer] max_height Specifies the maximum desired height, in pixels.
    # @return[String] String URL of the photo or nil upon error.
    def places_photo(photo_reference, max_width: nil, max_height: nil)
      unless (max_width || max_height)
        raise ArgumentError, "a max_width or max_height arg is required"
      end

      params = { photoreference: photo_reference }

      params[:maxwidth] = max_width if max_width
      params[:maxheight] = max_height if max_height

      image_response_decoder = -> (response) {
        location = response.location
        location.nil? ? nil : response.location.url.to_s
      }

      response = get('/maps/api/place/photo', params,
        custom_response_decoder: image_response_decoder)
    end

    # Returns Place predictions given a textual search string and optional
    # geographic bounds.
    #
    # @param[String] input_text: The text string on which to search.
    # @param[Integer] offset The position, in the input term, of the last
    #       character that the service uses to match predictions. For example,
    #       if the input is 'Google' and the offset is 3, the service will
    #       match on 'Goo'.
    # @param[String, Hash, Array] location The latitude/longitude value for
    #        which you wish to obtain the closest, human-readable address.
    # @param[Integer] radius Distance in meters within which to bias results.
    # @param[String] language The language in which to return results.
    # @param[String] types: Restricts the results to places matching the
    #        specified type. The full list of supported types is available here:
    #        https://developers.google.com/places/web-service/autocomplete#place_types
    # @param[Hash] components A component filter for which you wish to obtain a geocode,
    #       for example: ``{'administrative_area': 'TX','country': 'US'}``
    # @param[Boolean] strict_bounds Returns only those places that are strictly within
    #        the region defined by location and radius.
    # @return[Array] list of predictions
    def places_autocomplete(input_text, offset: nil, location: nil,
        radius: nil, language: nil, types: nil,
        components: nil, strict_bounds: false)

      return _autocomplete("", input_text, offset: offset,
                           location: location, radius: radius, language: language,
                           types: types, components: components,
                           strict_bounds: strict_bounds)
    end

    # Returns Place predictions given a textual search query, such as
    # "pizza near New York", and optional geographic bounds.

    # @param[String] input_text: The text query on which to search.
    # @param[Integer] offset: The position, in the input term, of the last
    #       character that the service uses to match predictions. For example,
    #       if the input is 'Google' and the offset is 3, the service will
    #       match on 'Goo'.
    # @param[String, Hash, Array] location: The latitude/longitude value for
    #       which you wish to obtain the closest, human-readable address.
    # @param[Number] radius: Distance in meters within which to bias results.
    # @param[String] language: The language in which to return results.
    # @return[Array] list of predictions
    def places_autocomplete_query(input_text, offset: nil, location: nil,
        radius: nil, language: nil)

      return _autocomplete("query", input_text, offset: offset,
        location: location, radius: radius, language: language)
    end

    private

    # Internal handler for ``places``, ``places_nearby``, and ``places_radar``.
    # See each method's docs for arg details.
    def _places(url_part,
        query: nil, location: nil, radius: nil, keyword: nil, language: nil,
        min_price: 0, max_price: 4, name: nil, open_now: nil,
        rank_by: nil, type: nil, page_token: nil)

      params = {}
      params[:query] = query if query
      params[:minprice] = min_price if min_price
      params[:maxprice] = max_price if max_price
      params[:location] = GoogleMapsService::Convert.latlng(location) if location
      params[:radius] = radius if radius
      params[:keyword] = keyword if keyword
      params[:language] = language if language
      params[:name] = GoogleMapsService::Convert.join_list(" ", name) if name
      params[:opennow] = "true" if open_now
      params[:rankby] = rank_by if rank_by
      params[:type] = type if type
      params[:pagetoken] = page_token if page_token

      return get('/maps/api/place/%ssearch/json' % url_part, params)
    end

    # Internal handler for ``autocomplete`` and ``autocomplete_query``.
    # See each method's docs for arg details.
    def _autocomplete(url_part, input_text, offset: nil, location: nil,
        radius: nil, language: nil, types: nil, components: nil,
        strict_bounds: false)

      params = { input: input_text }
      params[:offset] = offset if offset
      params[:location] = GoogleMapsService::Convert.latlng(location) if location
      params[:radius] = radius if radius
      params[:language] = language if language
      params[:types] = types if types
      params[:components] = GoogleMapsService::Convert.components(components) if components
      params[:strictbounds] = true if strict_bounds

      return get('/maps/api/place/%sautocomplete/json' % url_part, params).fetch(:predictions, [])
    end
  end
end
