require_relative '../../spec_helper'

describe Barometer::Query::Converter::ToGeocode, vcr: {
  match_requests_on: [:method, :uri],
  cassette_name: "Converter::ToGeocode"
} do

  it "converts :short_zipcode -> :geocode" do
    query = Barometer::Query.new('90210')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Beverly Hills, CA, United States'
    converted_query.format.should == :geocode
    converted_query.geo.country_code.should == 'US'
  end

  it "converts :zipcode -> :geocode" do
    query = Barometer::Query.new('90210-5555')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Beverly Hills, CA, United States'
    converted_query.format.should == :geocode
    converted_query.geo.country_code.should == 'US'
  end

  it "converts :coordinates -> :geocode" do
    query = Barometer::Query.new('40.756054,-73.986951')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Manhattan, NY, United States'
    converted_query.format.should == :geocode
    converted_query.geo.country_code.should == 'US'
  end

  it "converts :postalcode -> :geocode" do
    query = Barometer::Query.new('T5B 4M9')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Edmonton, AB, Canada'
    converted_query.format.should == :geocode
    converted_query.geo.country_code.should == 'CA'
  end

  it "converts :icao -> :geocode" do
    query = Barometer::Query.new('KSFO')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'San Francisco, CA, United States'
    converted_query.format.should == :geocode
    converted_query.geo.country_code.should == 'US'
  end

  it "converts :unknown -> :geocode" do
    query = Barometer::Query.new('Paris, France')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'Paris, IDF, France'
    converted_query.format.should == :geocode
    converted_query.geo.country_code.should == 'FR'
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('USGA0028')
    query.add_conversion(:icao, 'KSFO')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    converted_query.q.should == 'San Francisco, CA, United States'
    converted_query.format.should == :geocode
    converted_query.geo.country_code.should == 'US'
  end

  it "does not convert :weather_id" do
    query = Barometer::Query.new('USGA0028')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converter.call.should be_nil
  end

  it "does not convert :woe_id" do
    query = Barometer::Query.new('615702')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converter.call.should be_nil
  end
end
