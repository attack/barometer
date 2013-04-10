require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Converter::FromWeatherIdToGeocode, :vcr => {
  :match_requests_on => [:method, :uri],
  :cassette_name => "Converter::FromWeatherIdToGeocode"
} do

  it "converts :weather_id -> :geocode" do
    query = Barometer::Query.new('USGA0028')

    converter = Barometer::Converter::FromWeatherIdToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Atlanta, GA, US'
    converted_query.format.should == :geocode
    converted_query.country_code.should == 'US'
    converted_query.geo.should be_nil
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('30301')
    query.add_conversion(:weather_id, 'USGA0028')

    converter = Barometer::Converter::FromWeatherIdToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Atlanta, GA, US'
    converted_query.format.should == :geocode
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('90210')

    converter = Barometer::Converter::FromWeatherIdToGeocode.new(query)
    converter.call.should be_nil
  end
end
