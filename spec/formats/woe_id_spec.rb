require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "addressable/uri"

params_in_body = lambda do |request_1, request_2|
  a1 = Addressable::URI.parse("?#{request_1.body}")
  a2 = Addressable::URI.parse("?#{request_2.body}")
  a1.query_values == a2.query_values
end

describe Barometer::Query::Format::WoeID, :vcr => {
  :match_requests_on => [:method, :uri, params_in_body],
  :cassette_name => "Query::Format::WoeID"
} do
  before(:each) do
    Barometer.yahoo_placemaker_app_id = YAHOO_KEY
    @short_zipcode = "90210"
    @zipcode = @short_zipcode
    @long_zipcode = "90210-5555"
    @weather_id = "USGA0028"
    @postal_code = "T5B 4M9"
    @coordinates = "40.756054,-73.986951"
    @geocode = "New York, NY"
    @icao = "KSFO"
    @woe_id = "615702"
  end

  describe "and class methods" do
    describe "is?," do
      it "recognizes a valid 4 digit code format" do
        @query = "8775"
        Barometer::Query::Format::WoeID.is?(@query).should be_true
      end

      it "recognizes a valid 6 digit code format" do
        @query = "615702"
        Barometer::Query::Format::WoeID.is?(@query).should be_true
      end

      it "recognizes a valid 7 digit code format" do
        @query = "2459115"
        Barometer::Query::Format::WoeID.is?(@query).should be_true
      end

      it "recognizes a valid 5 digit code with a prepended 'w'" do
        @query = "w90210"
        Barometer::Query::Format::WoeID.is?(@query).should be_true
      end

      it "does not recognize a zip code" do
        @query = "90210"
        Barometer::Query::Format::WoeID.is?(@query).should be_false
      end

      it "recognizes non-valid format" do
        @query = "USGA0028"
        Barometer::Query::Format::WoeID.is?(@query).should be_false
      end
    end

    it "converts the query" do
      query_no_conversion = "2459115"
      query = Barometer::Query.new(query_no_conversion)
      query.q.should == query_no_conversion

      query_with_conversion = "w90210"
      query = Barometer::Query.new(query_with_conversion)
      query.q.should_not == query_with_conversion
      query.q.should == "90210"
    end

    describe "when reversing lookup" do
      it "reverses a valid woe_id (US)" do
        query = Barometer::Query.new(@woe_id)
        new_query = Barometer::Query::Format::WoeID.reverse(query)
        new_query.q.should == "Paris, France"
        new_query.country_code.should be_nil
        new_query.format.should == :geocode
        new_query.geo.should be_nil
      end
    end

    describe "when converting using 'to'," do
      it "converts from short_zipcode" do
        query = Barometer::Query.new(@short_zipcode)
        query.format.should == :short_zipcode
        new_query = Barometer::Query::Format::WoeID.to(query)
        new_query.q.should == "2363796"
        new_query.country_code.should == "US"
        new_query.format.should == :woe_id
        new_query.geo.should_not be_nil
      end

      it "converts from zipcode" do
        query = Barometer::Query.new(@zipcode)
        query.format = :zipcode
        query.format.should == :zipcode
        new_query = Barometer::Query::Format::WoeID.to(query)
        new_query.q.should == "2363796"
        new_query.country_code.should == "US"
        new_query.format.should == :woe_id
        new_query.geo.should_not be_nil
      end

      it "converts from postal code" do
        query = Barometer::Query.new(@postal_code)
        query.format = :postalcode
        query.format.should == :postalcode
        new_query = Barometer::Query::Format::WoeID.to(query)
        new_query.q.should == "8676"
        new_query.country_code.should == "CA"
        new_query.format.should == :woe_id
        new_query.geo.should be_nil
      end

      it "converts from coordinates" do
        query = Barometer::Query.new(@coordinates)
        query.format.should == :coordinates
        new_query = Barometer::Query::Format::WoeID.to(query)
        new_query.q.should == "12589342"
        new_query.country_code.should be_nil
        new_query.format.should == :woe_id
        new_query.geo.should be_nil
      end

      it "converts from geocode" do
        query = Barometer::Query.new(@geocode)
        query.format.should == :geocode
        new_query = Barometer::Query::Format::WoeID.to(query)
        new_query.q.should == "2459115"
        new_query.country_code.should be_nil
        new_query.format.should == :woe_id
        new_query.geo.should be_nil
      end

      it "converts from weather_id" do
        query = Barometer::Query.new(@weather_id)
        query.format.should == :weather_id
        new_query = Barometer::Query::Format::WoeID.to(query)
        new_query.q.should == "2357024"
        new_query.country_code.should == "US"
        new_query.format.should == :woe_id
        new_query.geo.should be_nil
      end

      it "converts from icao" do
        query = Barometer::Query.new(@icao)
        query.format.should == :icao
        new_query = Barometer::Query::Format::WoeID.to(query)
        new_query.q.should == "2487956"
        new_query.country_code.should == "US"
        new_query.format.should == :woe_id
        new_query.geo.should_not be_nil
      end
    end
  end
end
