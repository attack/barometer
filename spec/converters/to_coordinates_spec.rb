require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Converter::ToCoordinates, :vcr => {
  :match_requests_on => [:method, :uri],
  :cassette_name => "Converter::ToCoordinates"
} do

  it "converts :short_zipcode -> :coordinates" do
    query = Barometer::Query.new('90210')
    query.format = :short_zipcode

    converter = Barometer::Converter::ToCoordinates.new(query)
    converted_query = converter.call

    converted_query.q.should == '34.1030032,-118.4104684'
    converted_query.format.should == :coordinates
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "converts :zipcode -> :coordinates" do
    query = Barometer::Query.new('90210-5555')
    query.format = :zipcode

    converter = Barometer::Converter::ToCoordinates.new(query)
    converted_query = converter.call

    converted_query.q.should == '34.1030032,-118.4104684'
    converted_query.format.should == :coordinates
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "converts :geocode -> :coordinates" do
    query = Barometer::Query.new('New York, NY')
    query.format = :geocode

    converter = Barometer::Converter::ToCoordinates.new(query)
    converted_query = converter.call

    converted_query.q.should == '40.7143528,-74.00597309999999'
    converted_query.format.should == :coordinates
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "converts :postalcode -> :coordinates" do
    query = Barometer::Query.new('T5B 4M9')
    query.format = :postalcode

    converter = Barometer::Converter::ToCoordinates.new(query)
    converted_query = converter.call

    converted_query.q.should == '53.5721719,-113.4551835'
    converted_query.format.should == :coordinates
    converted_query.country_code.should == 'CA'
    converted_query.geo.should_not be_nil
  end

  it "converts :icao -> :coordinates" do
    query = Barometer::Query.new('KSFO')
    query.format = :icao

    converter = Barometer::Converter::ToCoordinates.new(query)
    converted_query = converter.call

    converted_query.q.should == '37.615223,-122.389979'
    converted_query.format.should == :coordinates
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('USGA0028')
    query.format = :weather_id
    query.add_conversion(:icao, 'KSFO')

    converter = Barometer::Converter::ToCoordinates.new(query)
    converted_query = converter.call

    converted_query.q.should == '37.615223,-122.389979'
    converted_query.format.should == :coordinates
    converted_query.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "does not convert :weather_id" do
    query = Barometer::Query.new('USGA0028')
    query.format = :weather_id

    converter = Barometer::Converter::ToCoordinates.new(query)
    converter.call.should be_nil
  end

  it "does not convert :woe_id" do
    query = Barometer::Query.new('615702')
    query.format = :woe_id

    converter = Barometer::Converter::ToCoordinates.new(query)
    converter.call.should be_nil
  end
end
