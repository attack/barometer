require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Converter::FromCoordinatesToNoaaStationId, vcr: {
  match_requests_on: [:method, :uri],
  cassette_name: "Converter::FromCoordinatesToNoaaStationId"
} do

  it "converts :coordinates -> :noaa_station_id" do
    query = Barometer::Query.new('34.10,-118.41')

    converter = Barometer::Query::Converter::FromCoordinatesToNoaaStationId.new(query)
    converted_query = converter.call

    converted_query.q.should == 'KSMO'
    converted_query.format.should == :noaa_station_id
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('90210')
    query.add_conversion(:coordinates, '34.10,-118.41')

    converter = Barometer::Query::Converter::FromCoordinatesToNoaaStationId.new(query)
    converted_query = converter.call

    converted_query.q.should == 'KSMO'
    converted_query.format.should == :noaa_station_id
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('KJFK')

    converter = Barometer::Query::Converter::FromCoordinatesToNoaaStationId.new(query)
    converter.call.should be_nil
  end
end
