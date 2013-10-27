require_relative '../../spec_helper'

describe Barometer::Query::Converter::FromGeocodeToCoordinates do
  it "converts :geocode -> :coordinates" do
    query = Barometer::Query.new('USNY0996')
    query.add_conversion(:geocode, 'New York, NY')

    query.geo = Barometer::Data::Geo.new(latitude: 40.7143528, longitude: -74.0059731, country_code: 'US')

    converter = Barometer::Query::Converter::FromGeocodeToCoordinates.new(query)
    converted_query = converter.call

    converted_query.q.should == '40.7143528,-74.0059731'
    converted_query.format.should == :coordinates
    converted_query.geo.country_code.should == 'US'
    converted_query.geo.should_not be_nil
  end

  it "does not convert other formats" do
    query = Barometer::Query.new('USGA0028')

    converter = Barometer::Query::Converter::FromGeocodeToCoordinates.new(query)
    converter.call.should be_nil
  end
end
