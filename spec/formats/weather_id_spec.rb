require 'spec_helper'

describe "Query::WeatherID" do
  
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
    
    before(:each) do
      @us_query = "USGA0000"
      @ca_query = "CAAB0000"
    end
    
    it "returns a format" do
      Barometer::Query::WeatherID.format.should == :weather_id
    end
    
    it "returns a country" do
      Barometer::Query::WeatherID.country_code(@us_query).should == "US"
      Barometer::Query::WeatherID.country_code(@ca_query).should == "CA"
    end
    
    it "returns a regex" do
      Barometer::Query::WeatherID.regex.should_not be_nil
      Barometer::Query::WeatherID.regex.is_a?(Regexp).should be_true
    end
    
    describe "is?," do
      
      before(:each) do
        @valid = "USGA0028"
        @invalid = "invalid"
      end
      
      it "recognizes a valid format" do
        Barometer::Query::WeatherID.is?(@valid).should be_true
      end
      
      it "recognizes non-valid format" do
        Barometer::Query::WeatherID.is?(@invalid).should be_false
      end
      
    end
  
    describe "when converting using 'to'," do
      
      before(:each) do
        Barometer.google_geocode_key = KEY
      end
      
      it "converts from short_zipcode" do
        Barometer::Query::WeatherID.to(@short_zipcode, :short_zipcode).first.should == "USCA0090"
      end

      it "converts from zipcode" do
        Barometer::Query::WeatherID.to(@zipcode, :zipcode).first.should == "USCA0090"
      end

      it "converts from coordinates" do
        Barometer::Query::WeatherID.to(@coordinates, :coordinates).first.should == "USNY0996"
      end

      it "converts from geocode" do
        Barometer::Query::WeatherID.to(@geocode, :geocode).first.should == "USNY0996"
      end

      it "returns nil for other formats" do
        Barometer::Query::WeatherID.to(@weather_id, :weather_id).should be_nil
        Barometer::Query::WeatherID.to(@postal_code, :postalcode).should be_nil
        Barometer::Query::WeatherID.to(@icao, :icao).should be_nil
      end

    end

  end
  
end