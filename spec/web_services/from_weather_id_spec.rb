require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WebService::FromWeatherId, :vcr => {
  :cassette_name => "WebService::FromWeatherId"
} do
  describe ".call," do
    it "returns nothing if query doesn't have weather_id format" do
      query = Barometer::Query.new("90210")
      Barometer::WebService::FromWeatherId.call(query).should be_nil
    end

    it "returns geocode & coordinates if the query is format weather_id" do
      query = Barometer::Query.new("USNY0996")

      response = Barometer::WebService::FromWeatherId.call(query)
      Barometer::WebService::FromWeatherId.parse_geocode(response).should == "New York, NY, US"
      Barometer::WebService::FromWeatherId.parse_coordinates(response).should == "40.67,-73.94"
    end

    it "returns a geocode & coordinates if the query has a weather_id conversion" do
      query = Barometer::Query.new("10001")
      query.add_conversion(:weather_id, "USNY0996")

      response = Barometer::WebService::FromWeatherId.call(query)
      Barometer::WebService::FromWeatherId.parse_geocode(response).should == "New York, NY, US"
      Barometer::WebService::FromWeatherId.parse_coordinates(response).should == "40.67,-73.94"
    end
  end
end
