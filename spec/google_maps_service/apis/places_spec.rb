require 'spec_helper'

describe GoogleMapsService::Apis::Places do
  include_context 'HTTP client'

  before(:example) do
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/place\/.*/)
      .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OK","results":[]}')
  end

  let(:location) { [-33.86746, 151.20709] }
  let(:type) { "liquor_store" }
  let(:language) { "en-AU" }
  let(:radius) { 100 }

  context 'places text search' do
    it 'should call Google Maps Web Service' do
      places = client.places('restaurant', location: location,
                             radius: radius, language: language,
                             min_price: 1, max_price: 4, open_now: true,
                             type: type)

      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/place/textsearch/json' +
        '?language=en-AU&location=-33.867460,151.207090&maxprice=4&minprice=1' +
        '&opennow=true&query=restaurant&radius=100&type=liquor_store&key=%s' %
        api_key)).to have_been_made
    end
  end

  context 'places nearby search' do
    it 'should call Google Maps Web Service' do
      places = client.places_nearby(location, keyword: 'foo',
                                    language: language, min_price: 1,
                                    max_price: 4, name: 'bar', open_now: true,
                                    rank_by: 'distance', type: type)

      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/place/nearbysearch/json' +
        '?keyword=foo&language=en-AU&location=-33.867460,151.207090&' +
        'maxprice=4&minprice=1&name=bar&opennow=true&rankby=distance&type=liquor_store&key=%s' %
        api_key)).to have_been_made
    end

    context "when rank by distance is not paired with a keyword, name, or type" do
      it 'should raise ArgumentError' do
        expect {
          places = client.places_nearby(location, rank_by: 'distance')
        }.to raise_error ArgumentError
      end
    end

    context "when rank by is set to distance and a radius is supplied" do
      it 'should raise ArgumentError' do
        expect {
          places = client.places_nearby(location, rank_by: 'distance',
            keyword: 'foo', radius: radius)
        }.to raise_error ArgumentError
      end
    end
  end

  context 'places radar search' do
    it 'should call Google Maps Web Service' do
      places = client.places_radar(location, radius, keyword: 'foo',
                                   min_price: 1, max_price: 4, name: 'bar',
                                   open_now: true, type: type)

      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/place/radarsearch/json' +
        '?keyword=foo&location=-33.867460,151.207090&' +
        'maxprice=4&minprice=1&name=bar&opennow=true&radius=100&type=liquor_store&key=%s' %
        api_key)).to have_been_made
    end

    context "when no keyword, name, or type is supplied" do
      it 'should raise ArgumentError' do
        expect {
          places = client.places_radar(location, radius)
        }.to raise_error ArgumentError
      end
    end
  end

  context 'place detail' do
    it 'should call Google Maps Web Service' do
      places = client.place('ChIJN1t_tDeuEmsRUsoyG83frY4', language: language)

      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/place/details/json' +
        '?language=en-AU&placeid=ChIJN1t_tDeuEmsRUsoyG83frY4&key=%s' %
        api_key)).to have_been_made
    end
  end

  context 'place photo' do
    it 'should call Google Maps Web Service' do
      ref = 'CnRvAAAAwMpdHeWlXl-lH0vp7lez4znKPIWSWvgvZFISdKx45AwJVP1Qp37YOrH7sqHMJ8C-vBDC546decipPHchJhHZL94RcTUfPa1jWzo-rSHaTlbNtjh-N68RkcToUCuY9v2HNpo5mziqkir37WU8FJEqVBIQ4k938TI3e7bf8xq-uwDZcxoUbO_ZJzPxremiQurAYzCTwRhE_V0'
      places = client.places_photo(ref, max_width: 100)

      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/place/photo' +
        '?maxwidth=100&photoreference=%s' % ref +
        '&key=%s' % api_key)).to have_been_made
    end

    context 'when no maxheight or maxwidth are supplied' do
      it 'should raise ArgumentError' do
        expect {
          places = client.places_photo("someref")
        }.to raise_error ArgumentError
      end
    end
  end

  context 'autocomplete' do
    it 'should call Google Maps Web Service' do
      client.places_autocomplete('Google', offset: 3,
                                 location: location,
                                 radius: radius,
                                 language: language,
                                 types: 'geocode',
                                 components: {'country': 'au'},
                                 strict_bounds: true)

      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/place/autocomplete/json' +
        '?components=country:au&input=Google&language=en-AU&' +
        'location=-33.867460,151.207090&offset=3&radius=100&' +
        'strictbounds=true&types=geocode&key=%s' % api_key)).to have_been_made

    end
  end

  context 'autocomplete query' do
    it 'should call Google Maps Web Service' do
      client.places_autocomplete_query('pizza near New York')      

      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/place/queryautocomplete/json' +
        '?input=pizza+near+New+York&key=%s' % api_key)).to have_been_made
    end
  end
end
