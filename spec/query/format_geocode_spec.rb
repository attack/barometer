require 'spec_helper'

describe "Query::Geocode" do
  
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
      Barometer::Query::Geocode.format.should == :geocode
    end
    
    it "returns a country" do
      Barometer::Query::Geocode.country_code.should be_nil
    end
    
    describe "is?," do
      
      before(:each) do
        @valid = "New York, NY"
      end
      
      it "recognizes a valid format" do
        Barometer::Query::Geocode.is?(@valid).should be_true
        Barometer::Query::Geocode.is?.should be_false
      end
      
    end
  
    describe "when converting using 'to'," do
      
      before(:each) do
        Barometer.force_geocode = false
      end

      it "converts from short_zipcode" do
        Barometer::Query::Geocode.to(@short_zipcode, :short_zipcode).first.should == "Beverly Hills, CA, USA"
      end

      it "converts from zipcode" do
        Barometer::Query::Geocode.to(@zipcode, :zipcode).first.should == "Beverly Hills, CA, USA"
      end
      
      it "converts from weather_id" do
       Barometer::Query::Geocode.to(@weather_id, :weather_id).first.should == "Atlanta, GA, USA"
      end
      
      it "converts from coordinates" do
        Barometer::Query::Geocode.to(@coordinates, :coordinates).first.should == "New York, NY, USA"
      end
      
      it "converts from icao" do
        Barometer::Query::Geocode.to(@icao, :icao).first.should == "San Francisco Airport, USA"
      end
      
      it "leaves postalcode untouched" do
        Barometer::Query::Geocode.to(@postalcode, :postalcode).first.should == @postalcode
      end
      
      it "leaves geocode untouched" do
        Barometer::Query::Geocode.to(@geocode, :geocode).first.should == "New York, NY, USA"
      end
      
      it "skips conversion unless Graticule enabled or no API key" do
        Barometer.google_geocode_key = nil
        Barometer.google_geocode_key.should be_nil
        Barometer::Query::Geocode.to(@coordinates, :coordinates).first.should == @coordinates
        Barometer.google_geocode_key = KEY
      end

    end
    
  end
  
end