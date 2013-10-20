require_relative '../../spec_helper'

describe Barometer::Query::Service::NoaaStation, vcr: {
  cassette_name: "Service::NoaaStation"
} do
  describe ".fetch," do
    it "returns nohing if query doesn't have coordinates format" do
      query = Barometer::Query.new("90210")
      Barometer::Query::Service::NoaaStation.fetch(query).should be_nil
    end

    it "returns a station_id if the query is format coordinates" do
      query = Barometer::Query.new("34.10,-118.41")
      Barometer::Query::Service::NoaaStation.fetch(query).should == "KSMO"
    end

    it "returns a station_id if the query has a corrdinates conversion" do
      query = Barometer::Query.new("90210")
      query.add_conversion(:coordinates, "34.10,-118.41")
      Barometer::Query::Service::NoaaStation.fetch(query).should == "KSMO"
    end
  end
end
