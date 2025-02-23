# Changelog

## Unreleased

## 0.7.0 - 2025-02-23

* Add Support for Routes API including compute_routes and compute_route_matrix
* Explicitly require base64 gem as required by ruby 3.4

## 0.6.3 - 2023-06-04

* Add Places API place, places, places_nearby and places_photo support

## 0.6.2 - 2023-03-18

* Add support for ruby 3.2
* Allow directions to return full response from API with response_slice option
* Allow geocode and reverse_geocode to return full response from API with response_slice option

## 0.6.1 - 2023-03-18

* Fix gem name in README file

## 0.6.0 - 2022-10-16

* Rename gem to google_maps_service_ruby

## 0.5.1 - 2022-08-30

* Fix User Agent not being included in request.
* Replace Travis CI with Github Actions.
* Format files with standardrb
* Update Code of Conduct

## 0.5.0 - 2022-08-24

* No changes.

## 0.5.0.b2

* Update retriable gem dependency to latest version

## 0.5.0.b1

* Support for Ruby <= 2.6 dropped
* Client implementation changed from Hurley to Net::HTTP. This has caused the following breaking changes:
    * request_options, ssl_options and connection can no longer be set
    * client object is no longer accessible
    * Hurley exceptions are no longer raised for connection issues

## 0.4.2

* Add nearest roads Google Roads API support

## 0.4.1

* Support JRuby 9.0.0.0
* Refactoring and more test coverage

## 0.4.0

* Use required positional and optional named parameters (_breaking changes_)
* Documentation with examples
* Documentation using markdown syntax
* Use OpenSSL instead Ruby-HMAC to sign url
* Customizeable HTTP client
* Fix QPS bug: ensure number of queue items is the given value

## 0.3.0

* QPS: Query per second
* Refactor lib

## 0.2.0

* Support Ruby >= 2.0.0
* Auto-retry connection when the request is failed and possible
* Restructure test (rspec) directory
* Refactor lib

## 0.1.0

* Initial release.
* Support Ruby >= 2.2
* [Google Maps Web Service API](https://developers.google.com/maps/documentation/webservices/) scope:
    - [Directions API](https://developers.google.com/maps/documentation/directions/)
    - [Distance Matrix API](https://developers.google.com/maps/documentation/distancematrix/)
    - [Elevation API](https://developers.google.com/maps/documentation/elevation/)
    - [Geocoding API](https://developers.google.com/maps/documentation/geocoding/)
    - [Time Zone API](https://developers.google.com/maps/documentation/timezone/)
    - [Roads API](https://developers.google.com/maps/documentation/roads/)
