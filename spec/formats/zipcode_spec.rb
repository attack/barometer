require 'spec_helper'

describe "Query::Zipcode" do
  
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
      Barometer::Query::Zipcode.format.should == :zipcode
    end
    
    it "returns a country" do
      Barometer::Query::Zipcode.country_code.should == "US"
      Barometer::Query::Zipcode.country_code("ignored").should == "US"
    end
    
    it "returns a regex" do
      Barometer::Query::Zipcode.regex.should_not be_nil
      Barometer::Query::Zipcode.regex.is_a?(Regexp).should be_true
    end
    
    describe "is?," do
      
      before(:each) do
        @valid = "90210-5555"
        @invalid = "invalid"
      end
      
      it "recognizes a valid format" do
        Barometer::Query::Zipcode.is?(@valid).should be_true
      end
      
      it "recognizes non-valid format" do
        Barometer::Query::Zipcode.is?(@invalid).should be_false
      end
      
    end
  
    describe "when converting using 'to'," do
      
      it "converts from short_zipcode" do
        Barometer::Query::Zipcode.to(@short_zipcode, :short_zipcode).should == @short_zipcode
      end
      
      it "returns nil for other formats" do
        Barometer::Query::Zipcode.to(@zipcode, :zipcode).should be_nil
        Barometer::Query::Zipcode.to(@weather_id, :weather_id).should be_nil
        Barometer::Query::Zipcode.to(@postal_code, :postalcode).should be_nil
        Barometer::Query::Zipcode.to(@coordinates, :coordinates).should be_nil
        Barometer::Query::Zipcode.to(@geocode, :geocode).should be_nil
        Barometer::Query::Zipcode.to(@icao, :icao).should be_nil
      end
      
    end
    
  end
  
end