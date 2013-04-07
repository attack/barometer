require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Converter::ToGeocode, :vcr => {
  :match_requests_on => [:method, :uri],
  :cassette_name => "Converter::ToGeocode"
} do

  it "converts :short_zipcode -> :geocode" do
    query = Barometer::Query.new('90210')
    query.format = :short_zipcode

    converter = Barometer::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Beverly Hills, CA, United States'
    converted_query.format.should == :geocode
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "converts :zipcode -> :geocode" do
    query = Barometer::Query.new('90210-5555')
    query.format = :zipcode

    converter = Barometer::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Beverly Hills, CA, United States'
    converted_query.format.should == :geocode
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "converts :coordinates -> :geocode" do
    query = Barometer::Query.new('40.756054,-73.986951')
    query.format = :coordinates

    converter = Barometer::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Manhattan, NY, United States'
    converted_query.format.should == :geocode
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "converts :postalcode -> :geocode" do
    query = Barometer::Query.new('T5B 4M9')
    query.format = :postalcode

    converter = Barometer::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Edmonton, AB, Canada'
    converted_query.format.should == :geocode
    converted_query.country_code.should == 'CA'
    converted_query.geo.should_not be_nil
  end

  it "converts :icao -> :geocode" do
    query = Barometer::Query.new('KSFO')
    query.format = :icao

    converter = Barometer::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'San Francisco, CA, United States'
    converted_query.format.should == :geocode
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('USGA0028')
    query.format = :weather_id
    query.add_conversion(:icao, 'KSFO')

    converter = Barometer::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'San Francisco, CA, United States'
    converted_query.format.should == :geocode
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "does not convert :weather_id" do
    query = Barometer::Query.new('USGA0028')
    query.format = :weather_id

    converter = Barometer::Converter::ToGeocode.new(query)
    converter.call.should be_nil
  end

  it "does not convert :woe_id" do
    query = Barometer::Query.new('615702')
    query.format = :woe_id

    converter = Barometer::Converter::ToGeocode.new(query)
    converter.call.should be_nil
  end
end
