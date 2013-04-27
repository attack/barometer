require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Converter::FromWoeOrWeatherIdToGeocode, :vcr => {
  :match_requests_on => [:method, :uri],
  :cassette_name => "Converter::FromWoeOrWeatherIdToGeocode"
} do

  it "converts :woe_id -> :geocode" do
    query = Barometer::Query.new('615702')

    converter = Barometer::Query::Converter::FromWoeOrWeatherIdToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Paris, France'
    converted_query.format.should == :geocode
    converted_query.country_code.should be_nil
    converted_query.geo.should be_nil
  end

  it "converts :woe_id -> :coordinates at the same time" do
    query = Barometer::Query.new('615702')

    converter = Barometer::Query::Converter::FromWoeOrWeatherIdToGeocode.new(query)
    converted_query = converter.call

    coordinate_conversion = query.get_conversion(:coordinates)
    coordinate_conversion.q.should == '48.86,2.34'
    coordinate_conversion.format.should == :coordinates
  end

  it "uses a previous :woe_id coversion (if needed) on the query" do
    query = Barometer::Query.new('40.697488,-73.979681')
    query.add_conversion(:woe_id, '615702')

    converter = Barometer::Query::Converter::FromWoeOrWeatherIdToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Paris, France'
    converted_query.format.should == :geocode
    converted_query.country_code.should be_nil
    converted_query.geo.should be_nil
  end

  it "converts :weather_id -> :geocode" do
    query = Barometer::Query.new('USGA0028')

    converter = Barometer::Query::Converter::FromWoeOrWeatherIdToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Atlanta, GA, US'
    converted_query.format.should == :geocode
    converted_query.country_code.should == 'US'
    converted_query.geo.should be_nil
  end

  it "converts :weather_id -> :coordinates at the same time" do
    query = Barometer::Query.new('USGA0028')

    converter = Barometer::Query::Converter::FromWoeOrWeatherIdToGeocode.new(query)
    converted_query = converter.call

    coordinate_conversion = query.get_conversion(:coordinates)
    coordinate_conversion.q.should == '33.75,-84.39'
    coordinate_conversion.format.should == :coordinates
  end

  it "uses a previous :weather_id coversion (if needed) on the query" do
    query = Barometer::Query.new('30301')
    query.add_conversion(:weather_id, 'USGA0028')

    converter = Barometer::Query::Converter::FromWoeOrWeatherIdToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Atlanta, GA, US'
    converted_query.format.should == :geocode
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('90210')

    converter = Barometer::Query::Converter::FromWoeOrWeatherIdToGeocode.new(query)
    converter.call.should be_nil
  end
end
