require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Service::ToWeatherId, :vcr => {
  :cassette_name => "WebService::ToWeatherId"
} do
  describe ".call," do
    it "returns nothing if query doesn't have geocode format" do
      query = Barometer::Query.new("90210")
      Barometer::Query::Service::ToWeatherId.call(query).should be_nil
    end

    it "returns a weather_id if the query is format geocode" do
      query = Barometer::Query.new("New York, NY")
      Barometer::Query::Service::ToWeatherId.call(query).should == "USNY0996"
    end

    it "returns a weather_id if the query has a corrdinates geocode" do
      query = Barometer::Query.new("10001")
      query.add_conversion(:geocode, "New York, NY")
      Barometer::Query::Service::ToWeatherId.call(query).should == "USNY0996"
    end
  end
end
