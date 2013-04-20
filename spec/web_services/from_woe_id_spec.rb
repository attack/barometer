require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WebService::FromWoeId, :vcr => {
  :cassette_name => "WebService::FromWoeId"
} do
  describe ".call," do
    it "returns nothing if query doesn't have woe_id format" do
      query = Barometer::Query.new("90210")
      Barometer::WebService::FromWoeId.call(query).should be_nil
    end

    it "returns geocode & coordinates if the query is format woe_id" do
      query = Barometer::Query.new("w2459115")

      response = Barometer::WebService::FromWoeId.call(query)
      Barometer::WebService::FromWoeId.parse_geocode(response).should == "New York, NY, United States"
      Barometer::WebService::FromWoeId.parse_coordinates(response).should == "40.71,-74.01"
    end

    it "returns a geocode & coordinates if the query has a woe_id conversion" do
      query = Barometer::Query.new("10001")
      query.add_conversion(:woe_id, "2459115")

      response = Barometer::WebService::FromWoeId.call(query)
      Barometer::WebService::FromWoeId.parse_geocode(response).should == "New York, NY, United States"
      Barometer::WebService::FromWoeId.parse_coordinates(response).should == "40.71,-74.01"
    end
  end
end
