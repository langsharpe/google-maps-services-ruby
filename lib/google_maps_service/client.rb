require "multi_json"
require "net/http"
require "retriable"
require "google_maps_service/errors"
require "google_maps_service/convert"
require "google_maps_service/url"
require "google_maps_service/apis/directions"
require "google_maps_service/apis/distance_matrix"
require "google_maps_service/apis/elevation"
require "google_maps_service/apis/geocoding"
require "google_maps_service/apis/places"
require "google_maps_service/apis/roads"
require "google_maps_service/apis/routes"
require "google_maps_service/apis/time_zone"

module GoogleMapsService
  # Core client functionality, common across all API requests (including performing
  # HTTP requests).
  class Client
    # Default Google Maps Web Service base endpoints
    DEFAULT_BASE_URL = "https://maps.googleapis.com"

    # Errors those could be retriable.
    RETRIABLE_ERRORS = [GoogleMapsService::Error::ServerError, GoogleMapsService::Error::RateLimitError]

    include GoogleMapsService::Apis::Directions
    include GoogleMapsService::Apis::DistanceMatrix
    include GoogleMapsService::Apis::Elevation
    include GoogleMapsService::Apis::Geocoding
    include GoogleMapsService::Apis::Places
    include GoogleMapsService::Apis::Roads
    include GoogleMapsService::Apis::Routes
    include GoogleMapsService::Apis::TimeZone

    # Secret key for accessing Google Maps Web Service.
    # Can be obtained at https://developers.google.com/maps/documentation/geocoding/get-api-key#key.
    # @return [String]
    attr_accessor :key

    # Client id for using Maps API for Work services.
    # @return [String]
    attr_accessor :client_id

    # Client secret for using Maps API for Work services.
    # @return [String]
    attr_accessor :client_secret

    # Timeout across multiple retriable requests, in seconds.
    # @return [Integer]
    attr_accessor :retry_timeout

    # Number of queries per second permitted.
    # If the rate limit is reached, the client will sleep for
    # the appropriate amount of time before it runs the current query.
    # @return [Integer]
    attr_reader :queries_per_second

    # Construct Google Maps Web Service API client.
    #
    # @example Setup API keys
    #   gmaps = GoogleMapsService::Client.new(key: 'Add your key here')
    #
    # @example Setup client IDs
    #   gmaps = GoogleMapsService::Client.new(
    #       client_id: 'Add your client id here',
    #       client_secret: 'Add your client secret here'
    #   )
    #
    # @example Setup time out and QPS limit
    #   gmaps = GoogleMapsService::Client.new(
    #       key: 'Add your key here',
    #       retry_timeout: 20,
    #       queries_per_second: 10
    #   )
    #
    # @option options [String] :key Secret key for accessing Google Maps Web Service.
    #   Can be obtained at https://developers.google.com/maps/documentation/geocoding/get-api-key#key.
    # @option options [String] :client_id Client id for using Maps API for Work services.
    # @option options [String] :client_secret Client secret for using Maps API for Work services.
    # @option options [Integer] :retry_timeout Timeout across multiple retriable requests, in seconds.
    # @option options [Integer] :queries_per_second Number of queries per second permitted.
    def initialize(**options)
      [:key, :client_id, :client_secret,
        :retry_timeout, :queries_per_second].each do |key|
        instance_variable_set(:"@#{key}", options[key] || GoogleMapsService.instance_variable_get(:"@#{key}"))
      end
      [:request_options, :ssl_options, :connection].each do |key|
        if options.has_key?(key)
          raise "GoogleMapsService::Client.new no longer supports #{key}."
        end
      end

      initialize_query_tickets
    end

    # Get the current HTTP client.
    # @deprecated
    def client
      raise "GoogleMapsService::Client.client is no longer implemented."
    end

    protected

    # Initialize QPS queue. QPS queue is a "tickets" for calling API
    def initialize_query_tickets
      if @queries_per_second
        @qps_queue = SizedQueue.new @queries_per_second
        @queries_per_second.times do
          @qps_queue << 0
        end
      end
    end

    # Create a new HTTP client.
    # @deprecated
    def new_client
      raise "GoogleMapsService::Client.new_client is no longer implemented."
    end

    # Build the user agent header
    # @return [String]
    def user_agent
      @user_agent ||= sprintf("google-maps-services-ruby/%s %s",
        GoogleMapsService::VERSION,
        GoogleMapsService::OS_VERSION)
    end

    # Make API call.
    #
    # @param [String] path Url path.
    # @param [String] params Request parameters.
    # @param [String] base_url Base Google Maps Web Service API endpoint url.
    # @param [Boolean] accepts_client_id Sign the request using API {#keys} instead of {#client_id}.
    # @param [Method] custom_response_decoder Custom method to decode raw API response.
    #
    # @return [Object] Decoded response body.
    def get(path, params, base_url: DEFAULT_BASE_URL, accepts_client_id: true, custom_response_decoder: nil)
      url = URI(base_url + generate_auth_url(path, params, accepts_client_id))

      Retriable.retriable timeout: @retry_timeout, on: RETRIABLE_ERRORS do |try|
        begin
          request_query_ticket
          request = Net::HTTP::Get.new(url)
          request["User-Agent"] = user_agent
          response = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == "https") do |http|
            http.request(request)
          end
        ensure
          release_query_ticket
        end

        return custom_response_decoder.call(response) if custom_response_decoder
        decode_response_body(response)
      end
    end

    # Make API call using an http post.
    #
    # @param [String] path Url path.
    # @param [String] params Request parameters.
    # @param [String] base_url Base Google Maps Web Service API endpoint url.
    # @param [Boolean] accepts_client_id Sign the request using API {#keys} instead of {#client_id}.
    # @param [Method] custom_response_decoder Custom method to decode raw API response.
    #
    # @return [Object] Decoded response body.
    def post(path, params, base_url: DEFAULT_BASE_URL, accepts_client_id: true, custom_response_decoder: nil, field_mask: nil)
      url = URI(base_url + generate_auth_url(path, {}, accepts_client_id))

      Retriable.retriable timeout: @retry_timeout, on: RETRIABLE_ERRORS do |try|
        begin
          request_query_ticket
          request = Net::HTTP::Post.new(url)
          request["User-Agent"] = user_agent
          request["X-Goog-FieldMask"] = field_mask if field_mask
          request["Content-Type"] = "application/json"
          request.body = MultiJson.dump(params)
          response = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == "https") do |http|
            http.request(request)
          end
        ensure
          release_query_ticket
        end

        return custom_response_decoder.call(response) if custom_response_decoder
        decode_response_body(response)
      end
    end

    # Get/wait the request "ticket" if QPS is configured.
    # Check for previous request time, it must be more than a second ago before calling new request.
    #
    # @return [void]
    def request_query_ticket
      if @qps_queue
        elapsed_since_earliest = Time.now - @qps_queue.pop
        sleep(1 - elapsed_since_earliest) if elapsed_since_earliest.to_f < 1
      end
    end

    # Release request "ticket".
    #
    # @return [void]
    def release_query_ticket
      @qps_queue << Time.now if @qps_queue
    end

    # Returns the path and query string portion of the request URL,
    # first adding any necessary parameters.
    #
    # @param [String] path The path portion of the URL.
    # @param [Hash] params URL parameters.
    # @param [Boolean] accepts_client_id Sign the request using API {#keys} instead of {#client_id}.
    #
    # @return [String]
    def generate_auth_url(path, params, accepts_client_id)
      # Deterministic ordering through sorting by key.
      # Useful for tests, and in the future, any caching.
      params = if params.is_a?(Hash)
        params.sort
      else
        params.dup
      end

      if accepts_client_id && @client_id && @client_secret
        params << ["client", @client_id]

        path = [path, GoogleMapsService::Url.urlencode_params(params)].join("?")
        sig = GoogleMapsService::Url.sign_hmac(@client_secret, path)
        return path + "&signature=" + sig
      end

      if @key
        params << ["key", @key]
        return path + "?" + GoogleMapsService::Url.urlencode_params(params)
      end

      raise ArgumentError, "Must provide API key for this API. It does not accept enterprise credentials."
    end

    # Extract and parse body response as hash. Throw an error if there is something wrong with the response.
    #
    # @param [Net::HTTPResponse] response Web API response.
    #
    # @return [Hash] Response body as hash. The hash key will be symbolized.
    def decode_response_body(response)
      check_response_status_code(response)
      body = MultiJson.load(response.body, symbolize_keys: true)
      check_body_error(response, body)
      body
    end

    # Check HTTP response status code. Raise error if the status is not 2xx.
    #
    # @param [Net::HTTPResponse] response Web API response.
    def check_response_status_code(response)
      case response.code.to_i
      when 200..300
        # Do-nothing
      when 301, 302, 303, 307
        raise GoogleMapsService::Error::RedirectError.new(response), sprintf("Redirect to %s", response.header[:location])
      when 401
        raise GoogleMapsService::Error::ClientError.new(response), "Unauthorized"
      when 304, 400, 402...500
        raise GoogleMapsService::Error::ClientError.new(response), "Invalid request"
      when 500..600
        raise GoogleMapsService::Error::ServerError.new(response), "Server error"
      end
    end

    # Check response body for error status.
    #
    # @param [Net::HTTPResponse] response Response object.
    # @param [Hash] body Response body.
    #
    # @return [void]
    def check_body_error(response, body)
      case body[:status]
      when "OK", "ZERO_RESULTS"
        # Do-nothing
      when "OVER_QUERY_LIMIT"
        raise GoogleMapsService::Error::RateLimitError.new(response), body[:error_message]
      when "REQUEST_DENIED"
        raise GoogleMapsService::Error::RequestDeniedError.new(response), body[:error_message]
      when "INVALID_REQUEST"
        raise GoogleMapsService::Error::InvalidRequestError.new(response), body[:error_message]
      else
        raise GoogleMapsService::Error::ApiError.new(response), body[:error_message]
      end
    end
  end
end
