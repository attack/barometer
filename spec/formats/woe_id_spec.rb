require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Query::WoeID" do
  
  before(:each) do
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
    
    it "returns a format" do
      Barometer::Query::Format::WoeID.format.should == :woe_id
    end
    
    it "returns a country" do
      Barometer::Query::Format::WoeID.country_code.should be_nil
    end
    
    it "returns a regex" do
      Barometer::Query::Format::WoeID.regex.should_not be_nil
      Barometer::Query::Format::WoeID.regex.is_a?(Regexp).should be_true
    end
    
    it "returns the convertable_formats" do
      Query::Format::WoeID.convertable_formats.should_not be_nil
      Query::Format::WoeID.convertable_formats.is_a?(Array).should be_true
      Query::Format::WoeID.convertable_formats.include?(:short_zipcode).should be_true
      Query::Format::WoeID.convertable_formats.include?(:zipcode).should be_true
      Query::Format::WoeID.convertable_formats.include?(:postalcode).should be_true
      Query::Format::WoeID.convertable_formats.include?(:weather_id).should be_true
      Query::Format::WoeID.convertable_formats.include?(:coordinates).should be_true
      Query::Format::WoeID.convertable_formats.include?(:icao).should be_true
      Query::Format::WoeID.convertable_formats.include?(:geocode).should be_true
    end
    
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
      
      it "requires a Barometer::Query object" do
        lambda { Barometer::Query::Format::WoeID.reverse }.should raise_error(ArgumentError)
        lambda { Barometer::Query::Format::WoeID.reverse("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@woe_id)
        query.is_a?(Barometer::Query).should be_true
        lambda { Barometer::Query::Format::WoeID.reverse(original_query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Query" do
        query = Barometer::Query.new(@woe_id)
        Barometer::Query::Format::WoeID.reverse(query).is_a?(Barometer::Query).should be_true
      end
      
      it "reverses a valid woe_id (US)" do
        query = Barometer::Query.new(@woe_id)
        new_query = Barometer::Query::Format::WoeID.reverse(query)
        new_query.q.should == "Paris, France"
        new_query.country_code.should be_nil
        new_query.format.should == :geocode
        new_query.geo.should be_nil
      end
      
      it "doesn't reverse an invalid weather_id" do
        query = Barometer::Query.new(@zipcode)
        Barometer::Query::Format::WoeID.reverse(query).should be_nil
      end
      
    end
  
    describe "when converting using 'to'," do
      
      before(:each) do
        Barometer.google_geocode_key = KEY
      end
      
      it "requires a Barometer::Query object" do
        lambda { Query::Format::WoeID.to }.should raise_error(ArgumentError)
        lambda { Query::Format::WoeID.to("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@woe_id)
        query.is_a?(Barometer::Query).should be_true
        lambda { Query::Format::WoeID.to(original_query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Query" do
        query = Barometer::Query.new(@geocode)
        Query::Format::WoeID.to(query).is_a?(Barometer::Query).should be_true
      end
      
      it "converts from short_zipcode" do
        query = Barometer::Query.new(@short_zipcode)
        query.format.should == :short_zipcode
        new_query = Query::Format::WoeID.to(query)
        new_query.q.should == "2363796"
        new_query.country_code.should == "US"
        new_query.format.should == :woe_id
        new_query.geo.should_not be_nil
      end
          
      it "converts from zipcode" do
        query = Barometer::Query.new(@zipcode)
        query.format = :zipcode
        query.format.should == :zipcode
        new_query = Query::Format::WoeID.to(query)
        new_query.q.should == "2363796"
        new_query.country_code.should == "US"
        new_query.format.should == :woe_id
        new_query.geo.should_not be_nil
      end
          
      it "converts from postal code" do
        query = Barometer::Query.new(@postal_code)
        query.format = :postalcode
        query.format.should == :postalcode
        new_query = Query::Format::WoeID.to(query)
        new_query.q.should == "8676"
        new_query.country_code.should == "CA"
        new_query.format.should == :woe_id
        new_query.geo.should be_nil
      end
          
      it "converts from coordinates" do
        query = Barometer::Query.new(@coordinates)
        query.format.should == :coordinates
        new_query = Query::Format::WoeID.to(query)
        new_query.q.should == "2459115"
        new_query.country_code.should be_nil
        new_query.format.should == :woe_id
        new_query.geo.should be_nil
      end
          
      it "converts from geocode" do
        query = Barometer::Query.new(@geocode)
        query.format.should == :geocode
        new_query = Query::Format::WoeID.to(query)
        new_query.q.should == "2459115"
        new_query.country_code.should be_nil
        new_query.format.should == :woe_id
        new_query.geo.should be_nil
      end
          
      it "converts from weather_id" do
        query = Barometer::Query.new(@weather_id)
        query.format.should == :weather_id
        new_query = Query::Format::WoeID.to(query)
        new_query.q.should == "2357024"
        new_query.country_code.should be_nil
        new_query.format.should == :woe_id
        new_query.geo.should be_nil
      end
          
      it "converts from icao" do
        query = Barometer::Query.new(@icao)
        query.format.should == :icao
        new_query = Query::Format::WoeID.to(query)
        new_query.q.should == "2451206"
        new_query.country_code.should == "US"
        new_query.format.should == :woe_id
        new_query.geo.should_not be_nil
      end
    
    end

  end
  
end