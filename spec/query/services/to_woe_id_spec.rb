require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require "addressable/uri"

params_in_body = lambda do |request_1, request_2|
  a1 = Addressable::URI.parse("?#{request_1.body}")
  a2 = Addressable::URI.parse("?#{request_2.body}")
  a1.query_values == a2.query_values
end

describe Barometer::Query::Service::ToWoeId, :vcr => {
  :match_requests_on => [:method, :uri, params_in_body],
  :cassette_name => "WebService::ToWoeId"
} do
  describe ".call," do
    before { Barometer.yahoo_placemaker_app_id = YAHOO_KEY }

    it "returns nothing if the Placemaker#app_id is missing" do
      Barometer.yahoo_placemaker_app_id = nil
      query = Barometer::Query.new("90210")
      Barometer::Query::Service::ToWoeId.call(query).should be_nil
    end

    it "returns nothing if query is an unsupported format" do
      query = Barometer::Query.new("90210")
      Barometer::Query::Service::ToWoeId.call(query).should be_nil
    end

    it "returns a weather_id if the query is format unknown" do
      query = Barometer::Query.new("Paris, France")
      Barometer::Query::Service::ToWoeId.call(query).should == "615702"
    end

    it "returns a weather_id if the query is format coordinates" do
      query = Barometer::Query.new("40.756054,-73.986951")
      Barometer::Query::Service::ToWoeId.call(query).should == "12761367"
    end

    it "returns a weather_id if the query is format postal code" do
      query = Barometer::Query.new("T5B 4M9")
      Barometer::Query::Service::ToWoeId.call(query).should == "24354344"
    end

    it "returns a weather_id if the query has a converted geocode" do
      query = Barometer::Query.new("10001")
      query.add_conversion(:geocode, "New York, NY")

      Barometer::Query::Service::ToWoeId.call(query).should == "2459115"
    end
  end
end
