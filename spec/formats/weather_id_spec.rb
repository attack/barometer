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
      @es_query = "SPXX0000"
    end
    
    it "returns a format" do
      Query::Format::WeatherID.format.should == :weather_id
    end
    
    it "returns a country" do
      Query::Format::WeatherID.country_code.should be_nil
      Query::Format::WeatherID.country_code("i").should be_nil
      Query::Format::WeatherID.country_code(@us_query).should == "US"
      Query::Format::WeatherID.country_code(@ca_query).should == "CA"
      Query::Format::WeatherID.country_code(@es_query).should == "ES"
    end
    
    it "returns a regex" do
      Query::Format::WeatherID.regex.should_not be_nil
      Query::Format::WeatherID.regex.is_a?(Regexp).should be_true
    end
    
    it "returns the convertable_formats" do
      Query::Format::WeatherID.convertable_formats.should_not be_nil
      Query::Format::WeatherID.convertable_formats.is_a?(Array).should be_true
      Query::Format::WeatherID.convertable_formats.include?(:short_zipcode).should be_true
      Query::Format::WeatherID.convertable_formats.include?(:zipcode).should be_true
      Query::Format::WeatherID.convertable_formats.include?(:coordinates).should be_true
      Query::Format::WeatherID.convertable_formats.include?(:geocode).should be_true
    end
    
    describe "is?," do
      
      before(:each) do
        @valid = "USGA0028"
        @invalid = "invalid"
      end
      
      it "recognizes a valid format" do
        Query::Format::WeatherID.is?(@valid).should be_true
      end
      
      it "recognizes non-valid format" do
        Query::Format::WeatherID.is?(@invalid).should be_false
      end
      
    end
    
    describe "fixing country codes" do
      
      it "doesn't fix a correct code" do
        Query::Format::WeatherID.send("_fix_country", "CA").should == "CA"
      end
      
      it "fixes an incorrect code" do
        Query::Format::WeatherID.send("_fix_country", "SP").should == "ES"
      end
      
    end
    
    describe "when reversing lookup" do
      
      it "requires a Barometer::Query object" do
        lambda { Query::Format::WeatherID.reverse }.should raise_error(ArgumentError)
        lambda { Query::Format::WeatherID.reverse("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@weather_id)
        query.is_a?(Barometer::Query).should be_true
        lambda { Query::Format::WeatherID.reverse(original_query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Query" do
        query = Barometer::Query.new(@weather_id)
        Query::Format::WeatherID.reverse(query).is_a?(Barometer::Query).should be_true
      end
      
      it "reverses a valid weather_id (US)" do
        query = Barometer::Query.new(@weather_id)
        new_query = Query::Format::WeatherID.reverse(query)
        new_query.q.should == "Atlanta, GA, US"
        new_query.country_code.should be_nil
        new_query.format.should == :geocode
        new_query.geo.should be_nil
      end
      
      it "doesn't reverse an invalid weather_id" do
        query = Barometer::Query.new(@zipcode)
        Query::Format::WeatherID.reverse(query).should be_nil
      end
      
    end
  
    describe "when converting using 'to'," do
      
      before(:each) do
        Barometer.google_geocode_key = KEY
      end
      
      it "requires a Barometer::Query object" do
        lambda { Query::Format::WeatherID.to }.should raise_error(ArgumentError)
        lambda { Query::Format::WeatherID.to("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@zipcode)
        query.is_a?(Barometer::Query).should be_true
        lambda { Query::Format::WeatherID.to(original_query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Query" do
        query = Barometer::Query.new(@short_zipcode)
        Query::Format::WeatherID.to(query).is_a?(Barometer::Query).should be_true
      end
      
      it "converts from short_zipcode" do
        query = Barometer::Query.new(@short_zipcode)
        query.format.should == :short_zipcode
        new_query = Query::Format::WeatherID.to(query)
        new_query.q.should == "USCA0090"
        new_query.country_code.should == "US"
        new_query.format.should == :weather_id
        new_query.geo.should_not be_nil
      end

      it "converts from zipcode" do
        query = Barometer::Query.new(@zipcode)
        query.format = :zipcode
        query.format.should == :zipcode
        new_query = Query::Format::WeatherID.to(query)
        new_query.q.should == "USCA0090"
        new_query.country_code.should == "US"
        new_query.format.should == :weather_id
        new_query.geo.should_not be_nil
      end

      it "converts from coordinates" do
        query = Barometer::Query.new(@coordinates)
        query.format.should == :coordinates
        new_query = Query::Format::WeatherID.to(query)
        new_query.q.should == "USNY0996"
        new_query.country_code.should == "US"
        new_query.format.should == :weather_id
        new_query.geo.should_not be_nil
      end

      it "converts from geocode" do
        query = Barometer::Query.new(@geocode)
        query.format.should == :geocode
        new_query = Query::Format::WeatherID.to(query)
        new_query.q.should == "USNY0996"
        new_query.country_code.should == "US"
        new_query.format.should == :weather_id
        new_query.geo.should be_nil
      end

      it "converts from icao" do
        query = Barometer::Query.new(@icao)
        query.format.should == :icao
        new_query = Query::Format::WeatherID.to(query)
        new_query.q.should == "USCA0987"
        new_query.country_code.should == "US"
        new_query.format.should == :weather_id
        new_query.geo.should_not be_nil
      end

      it "returns nil for other formats" do
        query = Barometer::Query.new(@weather_id)
        query.format.should == :weather_id
        new_query = Query::Format::WeatherID.to(query)
        new_query.should be_nil
        
        query = Barometer::Query.new(@postal_code)
        query.format.should == :postalcode
        new_query = Query::Format::WeatherID.to(query)
        new_query.should be_nil
      end

    end

  end
  
end