require 'spec_helper'

describe "Query::Coordinates" do
  
  before(:each) do
    @short_zipcode = "90210"
    @zipcode = @short_zipcode
    @long_zipcode = "90210-5555"
    @weather_id = "USGA0028"
    @postal_code = "T5B 4M9"
    @coordinates = "40.756054,-73.986951"
    @geocode = "New York, NY"
    @icao = "KSFO"
  end
  
  describe "and class methods" do
    
    it "returns a format" do
      Barometer::Query::Coordinates.format.should == :coordinates
    end
    
    it "returns a country" do
      Barometer::Query::Coordinates.country_code.should be_nil
    end
    
    it "returns a regex" do
      Barometer::Query::Coordinates.regex.should_not be_nil
      Barometer::Query::Coordinates.regex.is_a?(Regexp).should be_true
    end
    
    describe "is?," do
      
      before(:each) do
        @valid = "40.756054,-73.986951"
        @invalid = "invalid"
      end
      
      it "recognizes a valid format" do
        Barometer::Query::Coordinates.is?(@valid).should be_true
      end
      
      it "recognizes non-valid format" do
        Barometer::Query::Coordinates.is?(@invalid).should be_false
      end
      
    end
  
    describe "when converting using 'to'," do

      it "converts from short_zipcode" do
        Barometer::Query::Coordinates.to(@short_zipcode, :short_zipcode).first.should == "34.1030032,-118.4104684"
      end

      it "converts from zipcode" do
        Barometer::Query::Coordinates.to(@zipcode, :zipcode).first.should == "34.1030032,-118.4104684"
      end

      it "converts from weather_id" do
       Barometer::Query::Coordinates.to(@weather_id, :weather_id).first.should == "33.754487,-84.389663"
      end

      it "converts from geocode" do
        Barometer::Query::Coordinates.to(@geocode, :geocode).first.should == "40.756054,-73.986951"
      end

      it "converts from postal_code" do
        Barometer::Query::Coordinates.to(@postal_code, :postalcode).first.should == "53.570447,-113.456083"
      end

      it "converts from icao" do
        Barometer::Query::Coordinates.to(@icao, :icao).first.should == "37.615223,-122.389979"
      end

      it "returns nil for other formats" do
        Barometer::Query::Coordinates.to(@coordinates, :coordinates).should be_nil
      end

      it "skips conversion unless Graticule enabled or no API key" do
        Barometer.google_geocode_key = nil
        Barometer.google_geocode_key.should be_nil
        Barometer::Query::Coordinates.to(@geocode, :geocode).should be_nil
        Barometer.google_geocode_key = KEY
      end

    end
    
  end
  
end