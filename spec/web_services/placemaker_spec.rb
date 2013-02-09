require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "WebService::Placemaker" do

  before(:each) do
    @coordinates = "40.756054,-73.986951"
    @geocode = "New York, NY"
  end

  describe "and the class methods" do

    describe "fetch," do

      it "requires a Query object" do
        lambda { Barometer::WebService::Placemaker.fetch }.should raise_error(ArgumentError)
        lambda { Barometer::WebService::Placemaker.fetch("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@coordinates)
        query.is_a?(Barometer::Query).should be_true
        lambda { Barometer::WebService::Placemaker.fetch(query) }.should_not raise_error(ArgumentError)
      end

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
