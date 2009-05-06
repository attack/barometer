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
    
    it "returns the convertable_formats" do
      Barometer::Query::Coordinates.convertable_formats.should_not be_nil
      Barometer::Query::Coordinates.convertable_formats.is_a?(Array).should be_true
      Barometer::Query::Coordinates.convertable_formats.include?(:short_zipcode).should be_true
      Barometer::Query::Coordinates.convertable_formats.include?(:zipcode).should be_true
      Barometer::Query::Coordinates.convertable_formats.include?(:postalcode).should be_true
      Barometer::Query::Coordinates.convertable_formats.include?(:weather_id).should be_true
      Barometer::Query::Coordinates.convertable_formats.include?(:coordinates).should be_true
      Barometer::Query::Coordinates.convertable_formats.include?(:icao).should be_true
      Barometer::Query::Coordinates.convertable_formats.include?(:geocode).should be_true
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
      
      it "requires a Barometer::Query object" do
        lambda { Barometer::Query::Coordinates.to }.should raise_error(ArgumentError)
        lambda { Barometer::Query::Coordinates.to("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@zipcode)
        query.is_a?(Barometer::Query).should be_true
        lambda { Barometer::Query::Coordinates.to(original_query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Query" do
        query = Barometer::Query.new(@short_zipcode)
        Barometer::Query::Coordinates.to(query).is_a?(Barometer::Query).should be_true
      end

      it "converts from short_zipcode" do
        query = Barometer::Query.new(@short_zipcode)
        query.format.should == :short_zipcode
        new_query = Barometer::Query::Coordinates.to(query)
        new_query.q.should == "34.1030032,-118.4104684"
        new_query.country_code.should == "US"
        new_query.format.should == :coordinates
        new_query.geo.should_not be_nil
      end

      it "converts from zipcode" do
        query = Barometer::Query.new(@zipcode)
        query.format = :zipcode
        query.format.should == :zipcode
        new_query = Barometer::Query::Coordinates.to(query)
        new_query.q.should == "34.1030032,-118.4104684"
        new_query.country_code.should == "US"
        new_query.format.should == :coordinates
        new_query.geo.should_not be_nil
      end

      it "converts from weather_id" do
        query = Barometer::Query.new(@weather_id)
        query.format.should == :weather_id
        new_query = Barometer::Query::Coordinates.to(query)
        new_query.q.should == "33.754487,-84.389663"
        new_query.country_code.should == "US"
        new_query.format.should == :coordinates
        new_query.geo.should_not be_nil
      end

      it "converts from geocode" do
        query = Barometer::Query.new(@geocode)
        query.format.should == :geocode
        new_query = Barometer::Query::Coordinates.to(query)
        new_query.q.should == "40.756054,-73.986951"
        new_query.country_code.should == "US"
        new_query.format.should == :coordinates
        new_query.geo.should_not be_nil
      end

      it "converts from postal_code" do
        query = Barometer::Query.new(@postal_code)
        query.format.should == :postalcode
        new_query = Barometer::Query::Coordinates.to(query)
        new_query.q.should == "53.570447,-113.456083"
        new_query.country_code.should == "CA"
        new_query.format.should == :coordinates
        new_query.geo.should_not be_nil
      end

      it "converts from icao" do
        query = Barometer::Query.new(@icao)
        query.format.should == :icao
        new_query = Barometer::Query::Coordinates.to(query)
        new_query.q.should == "37.615223,-122.389979"
        new_query.country_code.should == "US"
        new_query.format.should == :coordinates
        new_query.geo.should_not be_nil
      end

      it "returns nil for other formats" do
        query = Barometer::Query.new(@coordinates)
        query.format.should == :coordinates
        new_query = Barometer::Query::Coordinates.to(query)
        new_query.q.should == "40.756201,-73.986513"
        new_query.country_code.should == "US"
        new_query.format.should == :coordinates
        new_query.geo.should_not be_nil
      end

      it "skips conversion when no API key" do
        Barometer.google_geocode_key = nil
        Barometer.google_geocode_key.should be_nil
        query = Barometer::Query.new(@short_zipcode)
        Barometer::Query::Coordinates.to(query).q.should be_nil
        Barometer.google_geocode_key = KEY
      end

    end
    
  end
  
end