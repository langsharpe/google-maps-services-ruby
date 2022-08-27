require 'spec_helper'

describe GoogleMapsService, :integration do
  before(:example) { WebMock.allow_net_connect! }
  after(:example) { WebMock.disable_net_connect! }

  it 'can make a real request' do
    client = GoogleMapsService::Client.new(key: ENV.fetch("GOOGLE_MAPS_API_KEY"))

    routes = client.directions(
      '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA',
      '2400 Amphitheatre Parkway, Mountain View, CA 94043, USA',
      mode: 'walking',
      alternatives: false,
    )

    expected_response = [{:bounds=>
     {:northeast=>{:lat=>37.4239218, :lng=>-122.0841125},
      :southwest=>{:lat=>37.4227776, :lng=>-122.0883048}},
    :copyrights=>"Map data ©2022 Google",
    :legs=>
     [{:distance=>{:text=>"0.3 mi", :value=>435},
       :duration=>{:text=>"6 mins", :value=>339},
       :end_address=>"2400 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
       :end_location=>{:lat=>37.4239218, :lng=>-122.0883048},
       :start_address=>
        "Google Building 40, 1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
       :start_location=>{:lat=>37.4227776, :lng=>-122.0841125},
       :steps=>
        [{:distance=>{:text=>"285 ft", :value=>87},
          :duration=>{:text=>"1 min", :value=>65},
          :end_location=>{:lat=>37.4228869, :lng=>-122.0850889},
          :html_instructions=>
           "Head <b>west</b> toward <b>Amphitheatre Pkwy</b><div style=\"font-size:0.9em\">Restricted usage road</div>",
          :polyline=>{:points=>"kclcFtpchV?B?HAJCvAIl@Eb@"},
          :start_location=>{:lat=>37.4227776, :lng=>-122.0841125},
          :travel_mode=>"WALKING"},
         {:distance=>{:text=>"105 ft", :value=>32},
          :duration=>{:text=>"1 min", :value=>23},
          :end_location=>{:lat=>37.4230758, :lng=>-122.085197},
          :html_instructions=>
           "Turn <b>right</b> toward <b>Amphitheatre Pkwy</b><div style=\"font-size:0.9em\">Restricted usage road</div>",
          :maneuver=>"turn-right",
          :polyline=>{:points=>"adlcFxvchV_@IE^"},
          :start_location=>{:lat=>37.4228869, :lng=>-122.0850889},
          :travel_mode=>"WALKING"},
         {:distance=>{:text=>"407 ft", :value=>124},
          :duration=>{:text=>"2 mins", :value=>99},
          :end_location=>{:lat=>37.4233365, :lng=>-122.0865416},
          :html_instructions=>"Turn <b>left</b> onto <b>Amphitheatre Pkwy</b>",
          :maneuver=>"turn-left",
          :polyline=>{:points=>"gelcFnwchV?FE`@ANCPCXCXAd@CTI^IVEV"},
          :start_location=>{:lat=>37.4230758, :lng=>-122.085197},
          :travel_mode=>"WALKING"},
         {:distance=>{:text=>"377 ft", :value=>115},
          :duration=>{:text=>"1 min", :value=>81},
          :end_location=>{:lat=>37.423724, :lng=>-122.0874863},
          :html_instructions=>
           "Slight <b>left</b> to stay on <b>Amphitheatre Pkwy</b>",
          :maneuver=>"turn-slight-left",
          :polyline=>{:points=>"{flcFz_dhV?DCb@CNAL?\\Ed@ANEb@CHE?i@K"},
          :start_location=>{:lat=>37.4233365, :lng=>-122.0865416},
          :travel_mode=>"WALKING"},
         {:distance=>{:text=>"46 ft", :value=>14},
          :duration=>{:text=>"1 min", :value=>20},
          :end_location=>{:lat=>37.4238089, :lng=>-122.0876103},
          :html_instructions=>
           "Turn <b>right</b> toward <b>Amphitheatre Pkwy</b>",
          :maneuver=>"turn-right",
          :polyline=>{:points=>"gilcFxedhVGAIX"},
          :start_location=>{:lat=>37.423724, :lng=>-122.0874863},
          :travel_mode=>"WALKING"},
         {:distance=>{:text=>"207 ft", :value=>63},
          :duration=>{:text=>"1 min", :value=>51},
          :end_location=>{:lat=>37.4239218, :lng=>-122.0883048},
          :html_instructions=>
           "Turn <b>left</b> onto <b>Amphitheatre Pkwy</b><div style=\"font-size:0.9em\">Destination will be on the right</div>",
          :maneuver=>"turn-left",
          :polyline=>{:points=>"yilcFpfdhVMlAA\\E\\"},
          :start_location=>{:lat=>37.4238089, :lng=>-122.0876103},
          :travel_mode=>"WALKING"}],
       :traffic_speed_entry=>[],
       :via_waypoint=>[]}],
    :overview_polyline=>
     {:points=>"kclcFtpchVEpBOpA_@IE^Eh@E`@Gr@Ez@Sv@E\\Gr@Aj@QbBo@KGAIXOjBE\\"},
    :summary=>"Amphitheatre Pkwy",
    :warnings=>
     ["Walking directions are in beta. Use caution – This route may be missing sidewalks or pedestrian paths."],
    :waypoint_order=>[]}]

    expect(routes).to eq(expected_response)
  end
end
