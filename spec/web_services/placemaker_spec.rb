require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WebService::Placemaker do
  before(:each) do
    Barometer.yahoo_placemaker_app_id = YAHOO_KEY
    @coordinates = "40.756054,-73.986951"
    @geocode = "New York, NY"
  end

  describe "and the class methods" do
    describe "fetch," do
      # it "detects the key" do
      #   query = Barometer::Query.new(@zipcode)
      #   Barometer.google_geocode_key = nil
      #   Barometer::WebService::Geocode.fetch(query).should be_nil
      #   Barometer.google_geocode_key = KEY
      #   Barometer::WebService::Geocode.fetch(query).should_not be_nil
      # end
      #
      # it "returns a Geo object" do
      #   query = Barometer::Query.new(@zipcode)
      #   Barometer::WebService::Geocode.fetch(query).is_a?(Data::Geo).should be_true
      # end

    end

    # it "detects the Google Geocode Key" do
    #   Barometer.google_geocode_key = nil
    #   Barometer::WebService::Geocode.send("_has_geocode_key?").should be_false
    #   Barometer.google_geocode_key = KEY
    #   Barometer::WebService::Geocode.send("_has_geocode_key?").should be_true
    # end
  end
end
