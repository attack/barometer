require_relative '../../spec_helper'

describe Barometer::Query::Service::ToWeatherId, vcr: {
  cassette_name: "Service::ToWeatherId"
} do
  describe ".call," do
    it "returns nothing if query doesn't have a supported format" do
      query = Barometer::Query.new("90210")
      Barometer::Query::Service::ToWeatherId.call(query).should be_nil
    end

    it "returns a weather_id if the query is format unknown" do
      query = Barometer::Query.new("Paris, France")
      Barometer::Query::Service::ToWeatherId.call(query).should == "FRXX0076"
    end

    it "returns a weather_id if the query has a supported conversion" do
      query = Barometer::Query.new("10001")
      query.add_conversion(:geocode, "New York, NY")
      Barometer::Query::Service::ToWeatherId.call(query).should == "USNY0996"
    end
  end
end
