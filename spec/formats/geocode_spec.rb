require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
      Query::Format::Geocode.format.should == :geocode
    end
    
    it "returns a country" do
      Query::Format::Geocode.country_code.should be_nil
    end
    
    it "returns the convertable_formats" do
      Query::Format::Geocode.convertable_formats.should_not be_nil
      Query::Format::Geocode.convertable_formats.is_a?(Array).should be_true
      Query::Format::Geocode.convertable_formats.include?(:short_zipcode).should be_true
      Query::Format::Geocode.convertable_formats.include?(:zipcode).should be_true
      Query::Format::Geocode.convertable_formats.include?(:coordinates).should be_true
      Query::Format::Geocode.convertable_formats.include?(:weather_id).should be_true
      Query::Format::Geocode.convertable_formats.include?(:icao).should be_true
    end
    
    describe "is?," do
      
      before(:each) do
        @valid = "New York, NY"
      end
      
      it "recognizes a valid format" do
        Query::Format::Geocode.is?(@valid).should be_true
        Query::Format::Geocode.is?.should be_false
      end
      
    end
  
    describe "when converting using 'to'," do
      
      before(:each) do
        Barometer.force_geocode = false
      end
      
      it "requires a Barometer::Query object" do
        lambda { Query::Format::Geocode.to }.should raise_error(ArgumentError)
        lambda { Query::Format::Geocode.to("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@zipcode)
        query.is_a?(Barometer::Query).should be_true
        lambda { Query::Format::Geocode.to(query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Query" do
        query = Barometer::Query.new(@short_zipcode)
        Query::Format::Geocode.to(query).is_a?(Barometer::Query).should be_true
      end

      it "converts from short_zipcode" do
        query = Barometer::Query.new(@short_zipcode)
        query.format.should == :short_zipcode
        new_query = Query::Format::Geocode.to(query)
        new_query.q.should == "Beverly Hills, CA, USA"
        new_query.country_code.should == "US"
        new_query.format.should == :geocode
        new_query.geo.should_not be_nil
      end

      it "converts from zipcode" do
        query = Barometer::Query.new(@zipcode)
        query.format = :zipcode
        query.format.should == :zipcode
        new_query = Query::Format::Geocode.to(query)
        new_query.q.should == "Beverly Hills, CA, USA"
        new_query.country_code.should == "US"
        new_query.format.should == :geocode
        new_query.geo.should_not be_nil
      end
      
      it "converts from weather_id" do
        query = Barometer::Query.new(@weather_id)
        query.format.should == :weather_id
        new_query = Query::Format::Geocode.to(query)
        new_query.q.should == "Atlanta, GA, US"
        new_query.country_code.should be_nil
        new_query.format.should == :geocode
        new_query.geo.should be_nil
      end
      
      it "converts from coordinates" do
        query = Barometer::Query.new(@coordinates)
        query.format.should == :coordinates
        new_query = Query::Format::Geocode.to(query)
        new_query.q.should == "New York, NY, USA"
        new_query.country_code.should == "US"
        new_query.format.should == :geocode
        new_query.geo.should_not be_nil
      end
      
      it "converts from icao" do
        query = Barometer::Query.new(@icao)
        query.format.should == :icao
        new_query = Query::Format::Geocode.to(query)
        new_query.q.should == "Millbrae, CA, USA"
        new_query.country_code.should == "US"
        new_query.format.should == :geocode
        new_query.geo.should_not be_nil
      end
      
      it "does not convert postalcode" do
        query = Barometer::Query.new(@postal_code)
        query.format.should == :postalcode
        new_query = Query::Format::Geocode.to(query)
        new_query.should be_nil
      end
      
      it "leaves geocode untouched" do
        query = Barometer::Query.new(@geocode)
        query.format.should == :geocode
        new_query = Query::Format::Geocode.to(query)
        new_query.q.should == "New York, NY"
        new_query.country_code.should be_nil
        new_query.format.should == :geocode
        new_query.geo.should be_nil
      end
      
      it "skips conversion when no API key" do
        Barometer.google_geocode_key = nil
        Barometer.google_geocode_key.should be_nil
        query = Barometer::Query.new(@coordinates)
        Query::Format::Geocode.to(query).q.should be_nil
        Barometer.google_geocode_key = KEY
      end

    end
    
    describe "when geocoding" do
      
      it "requires a Barometer::Query object" do
        lambda { Query::Format::Geocode.geocode }.should raise_error(ArgumentError)
        lambda { Query::Format::Geocode.geocode("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@zipcode)
        query.is_a?(Barometer::Query).should be_true
        lambda { Query::Format::Geocode.geocode(original_query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Query" do
        query = Barometer::Query.new(@short_zipcode)
        Query::Format::Geocode.geocode(query).is_a?(Barometer::Query).should be_true
      end
      
      it "converts from short_zipcode" do
        query = Barometer::Query.new(@short_zipcode)
        query.format.should == :short_zipcode
        new_query = Query::Format::Geocode.geocode(query)
        new_query.q.should == "Beverly Hills, CA, USA"
        new_query.country_code.should == "US"
        new_query.format.should == :geocode
        new_query.geo.should_not be_nil
      end

    end
    
    it "doesn't define a regex" do
      lambda { Query::Format::Geocode.regex }.should raise_error(NotImplementedError)
    end
    
  end
  
end