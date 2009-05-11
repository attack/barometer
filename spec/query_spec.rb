require 'spec_helper'

describe "Query" do
  
  before(:each) do
    @short_zipcode = "90210"
    @zipcode = @short_zipcode
    @long_zipcode = "90210-5555"
    @weather_id = "USGA0028"
    @postal_code = "T5B 4M9"
    @coordinates = "40.756054,-73.986951"
    @geocode = "New York, NY"
    @icao = "KSFO"
    
    # actual conversions
    @zipcode_to_coordinates = "34.1030032,-118.4104684"
    @zipcode_to_geocode = "Beverly Hills, CA, USA"
    @zipcode_to_weather_id = "USCA0090"
    @postalcode_to_coordinates = "53.570447,-113.456083"
    @geocode_to_coordinates = "40.756054,-73.986951"
    @geocode_to_weather_id = "USNY0996"
    @coordinates_to_geocode = "New York, NY, USA"
    @coordinates_to_weather_id = "USNY0996"
    @icao_to_coordinates = "37.615223,-122.389979"
    @icao_to_geocode = "San Francisco Airport, USA"
    @icao_to_weather_id = "USCA0987"
    
    Barometer.google_geocode_key = nil
    #Barometer.skip_graticule = true
  end
  
  describe "determines the query format" do
    
    before(:each) do
      @query = Barometer::Query.new
      @query.country_code.should be_nil
    end

    it "recognizes a short zip code" do
      @query.q = @short_zipcode
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :short_zipcode
      @query.country_code.should == "US"
    end

    it "recognizes a zip code" do
      @query.q = @long_zipcode
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :zipcode
      @query.country_code.should == "US"
    end
    
    it "recognizes a postal code" do
      @query.q = @postal_code
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :postalcode
      @query.country_code.should == "CA"
    end
    
    it "recognizes icao" do
      @query.q = @icao
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :icao
      @query.country_code.should == "US"
    end
    
    it "recognizes weather_id" do
      @query.q = @weather_id
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :weather_id
      @query.country_code.should == "US"
    end
    
    it "recognizes latitude/longitude" do
      @query.q = @coordinates
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :coordinates
      @query.country_code.should be_nil
    end
    
    it "defaults to a general geo_location" do
      @query.q = @geocode
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :geocode
      @query.country_code.should be_nil
    end
    
  end
  
  describe "when initialized" do
    
    before(:each) do
      @query = Barometer::Query.new
    end
    
    it "responds to q" do
      @query.q.should be_nil
    end
    
    it "responds to format" do
      @query.format.should be_nil
    end
    
    it "responds to country_code" do
      @query.country_code.should be_nil
    end
    
    it "sets the query" do
      query = Barometer::Query.new(@geocode)
      query.q.should == @geocode
    end
    
    it "determines the format" do
      query = Barometer::Query.new(@geocode)
      query.format.should_not be_nil
    end
    
    it "responds to google_api_key" do
      Barometer.google_geocode_key.should be_nil
    end
    
    it "defaults to the Module geocode key" do
      key = "KEY"
      Barometer.google_geocode_key = key
      Barometer.google_geocode_key.should == key
    end
    
    it "responds to geo" do
      @query.geo.should be_nil
    end
    
  end
  
  describe "when returning the query to a Weather API" do
    
    it "raises an error if there are NO acceptable formats" do
      acceptable_formats = nil
      query = Barometer::Query.new
      lambda { query.convert!(acceptable_formats) }.should raise_error
      
      acceptable_formats = []
      lambda { query.convert!(acceptable_formats) }.should raise_error
    end
    
    describe "and the query is already the preferred format" do
      
      it "returns the short_zipcode untouched" do
        preferred = [:short_zipcode]
        query = Barometer::Query.new(@short_zipcode)
        query.convert!(preferred).q.should == @short_zipcode
        query.country_code.should == "US"
      end
      
      it "returns the long_zipcode untouched" do
        preferred = [:zipcode]
        query = Barometer::Query.new(@long_zipcode)
        query.convert!(preferred).q.should == @long_zipcode
        query.country_code.should == "US"
      end
      
      it "returns the postalcode untouched" do
        preferred = [:postalcode]
        query = Barometer::Query.new(@postal_code)
        query.convert!(preferred).q.should == @postal_code
        query.country_code.should == "CA"
      end
      
      it "returns the icao untouched" do
        preferred = [:icao]
        query = Barometer::Query.new(@icao)
        query.convert!(preferred).q.should == @icao
      end
      
      it "returns the coordinates untouched" do
        preferred = [:coordinates]
        query = Barometer::Query.new(@coordinates)
        query.convert!(preferred).q.should == @coordinates
      end
      
      it "returns the geocode untouched" do
        preferred = [:geocode]
        query = Barometer::Query.new(@geocode)
        query.convert!(preferred).q.should == @geocode
      end
      
    end
    
    describe "and the query needs converting" do
      
      describe "with an intial format of :short_zipcode," do
        
        before(:each) do
          @query = Barometer::Query.new(@short_zipcode)
          Barometer.google_geocode_key = KEY
        end
        
        it "converts to zipcode" do
          acceptable_formats = [:zipcode]
          query = @query.convert!(acceptable_formats)
          query.q.should == @zipcode
          query.country_code.should == "US"
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          query = @query.convert!(acceptable_formats)
          query.q.should == @zipcode_to_coordinates
          query.country_code.should == "US"
        end
        
        it "converts to geocode" do
          acceptable_formats = [:geocode]
          query = @query.convert!(acceptable_formats)
          query.q.should == @zipcode_to_geocode
          query.country_code.should == "US"
        end
        
        it "converts to weather_id" do
          acceptable_formats = [:weather_id]
          query = @query.convert!(acceptable_formats)
          query.q.should == @zipcode_to_weather_id
          query.country_code.should == "US"
        end
        
        it "skips converting to icao" do
          acceptable_formats = [:icao]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
      end
      
      describe "with an intial format of :zipcode," do
        
        before(:each) do
          @query = Barometer::Query.new(@zipcode)
          Barometer.google_geocode_key = KEY
          Barometer.force_geocode = false
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          query = @query.convert!(acceptable_formats)
          query.q.should == @zipcode_to_coordinates
          query.country_code.should == "US"
        end
        
        it "converts to geocode" do
          acceptable_formats = [:geocode]
          query = @query.convert!(acceptable_formats)
          query.q.should == @zipcode_to_geocode
          query.country_code.should == "US"
        end
        
        it "skips converting to icao" do
          acceptable_formats = [:icao]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to short_zipcode" do
          @query = Barometer::Query.new(@long_zipcode)
          acceptable_formats = [:short_zipcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "converts to weather_id" do
          acceptable_formats = [:weather_id]
          query = @query.convert!(acceptable_formats)
          query.q.should == @zipcode_to_weather_id
          query.country_code.should == "US"
        end
        
      end
      
      describe "with an intial format of :postalcode," do
        
        before(:each) do
          @query = Barometer::Query.new(@postal_code)
          Barometer.google_geocode_key = KEY
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          query = @query.convert!(acceptable_formats)
          query.q.should == @postalcode_to_coordinates
          query.country_code.should == "CA"
        end
        
        it "skips converting to geocode" do
          acceptable_formats = [:geocode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to icao" do
          acceptable_formats = [:icao]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to short_zipcode" do
          acceptable_formats = [:short_zipcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to weather_id" do
          acceptable_formats = [:weather_id]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
      end
      
      describe "with an intial format of :icao," do
        
        before(:each) do
          @query = Barometer::Query.new(@icao)
          Barometer.google_geocode_key = KEY
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          query = @query.convert!(acceptable_formats)
          query.q.should == @icao_to_coordinates
          query.country_code.should == "US"
        end
        
        it "converts to geocode" do
          acceptable_formats = [:geocode]
          query = @query.convert!(acceptable_formats)
          query.q.should == @icao_to_geocode
          query.country_code.should == "US"
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to short_zipcode" do
          acceptable_formats = [:short_zipcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "converts to weather_id" do
          acceptable_formats = [:weather_id]
          query = @query.convert!(acceptable_formats)
          query.q.should == @icao_to_weather_id
          query.country_code.should == "US"
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
      end
      
      describe "with an intial format of :geocode," do
        
        before(:each) do
          @query = Barometer::Query.new(@geocode)
          Barometer.google_geocode_key = KEY
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          query = @query.convert!(acceptable_formats)
          query.q.should == @geocode_to_coordinates
          query.country_code.should == "US"
        end
        
        it "skips converting to icao" do
          acceptable_formats = [:icao]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to short_zipcode" do
          acceptable_formats = [:short_zipcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "converts to weather_id" do
          acceptable_formats = [:weather_id]
          query = @query.convert!(acceptable_formats)
          query.q.should == @geocode_to_weather_id
          query.country_code.should == "US"
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
      end
      
      describe "with an intial format of :coordinates," do
        
        before(:each) do
          @query = Barometer::Query.new(@coordinates)
          Barometer.google_geocode_key = KEY
        end
        
        it "converts to geocode" do
          acceptable_formats = [:geocode]
          query = @query.convert!(acceptable_formats)
          query.q.should == @coordinates_to_geocode
          query.country_code.should == "US"
        end
        
        it "skips converting to icao" do
          acceptable_formats = [:icao]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "skips converting to short_zipcode" do
          acceptable_formats = [:short_zipcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
        it "converts to weather_id" do
          acceptable_formats = [:weather_id]
          query = @query.convert!(acceptable_formats)
          query.q.should == @coordinates_to_weather_id
          query.country_code.should == "US"
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          query = @query.convert!(acceptable_formats)
          query.should be_nil
        end
        
      end
      
    end
    
  end
  
end