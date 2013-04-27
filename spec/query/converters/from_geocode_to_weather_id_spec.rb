require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Converter::FromGeocodeToWeatherId, :vcr => {
  :match_requests_on => [:method, :uri],
  :cassette_name => "Converter::FromGeocodeToWeatherId"
} do

  it "converts :geocode -> :weather_id" do
    query = Barometer::Query.new('New York, NY')

    converter = Barometer::Query::Converter::FromGeocodeToWeatherId.new(query)
    converted_query = converter.call

    converted_query.q.should == 'USNY0996'
    converted_query.format.should == :weather_id
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('KJFK')
    query.add_conversion(:geocode, 'New York, NY')

    converter = Barometer::Query::Converter::FromGeocodeToWeatherId.new(query)
    converted_query = converter.call

    converted_query.q.should == 'USNY0996'
    converted_query.format.should == :weather_id
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('KJFK')

    converter = Barometer::Query::Converter::FromGeocodeToWeatherId.new(query)
    converter.call.should be_nil
  end
end
