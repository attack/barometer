require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WebService::YahooGeocode, :vcr => {
  :cassette_name => "WebService::YahooGeocode"
} do
  describe ".call," do
    it "returns nothing if query doesn't have weather_id or woe_id format" do
      query = Barometer::Query.new("90210")
      Barometer::WebService::YahooGeocode.call(query).should be_nil
    end

    it "returns geocode & coordinates if the query is format weather_id" do
      query = Barometer::Query.new("USNY0996")

      response = Barometer::WebService::YahooGeocode.call(query)
      Barometer::WebService::YahooGeocode.parse_geocode(response).should == "New York, NY, US"
      Barometer::WebService::YahooGeocode.parse_coordinates(response).should == "40.67,-73.94"
    end

    it "returns a geocode & coordinates if the query has a weather_id conversion" do
      query = Barometer::Query.new("10001")
      query.add_conversion(:weather_id, "USNY0996")

      response = Barometer::WebService::YahooGeocode.call(query)
      Barometer::WebService::YahooGeocode.parse_geocode(response).should == "New York, NY, US"
      Barometer::WebService::YahooGeocode.parse_coordinates(response).should == "40.67,-73.94"
    end

    it "returns geocode & coordinates if the query is format woe_id" do
      query = Barometer::Query.new("w2459115")

      response = Barometer::WebService::YahooGeocode.call(query)
      Barometer::WebService::YahooGeocode.parse_geocode(response).should == "New York, NY, United States"
      Barometer::WebService::YahooGeocode.parse_coordinates(response).should == "40.71,-74.01"
    end

    it "returns a geocode & coordinates if the query has a woe_id conversion" do
      query = Barometer::Query.new("10001")
      query.add_conversion(:woe_id, "2459115")

      response = Barometer::WebService::YahooGeocode.call(query)
      Barometer::WebService::YahooGeocode.parse_geocode(response).should == "New York, NY, United States"
      Barometer::WebService::YahooGeocode.parse_coordinates(response).should == "40.71,-74.01"
    end
  end
end
