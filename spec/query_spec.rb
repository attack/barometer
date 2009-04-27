require 'spec_helper'

describe "Query" do
  
  before(:each) do
    @zipcode = "90210"
    @postal_code = "T5B 4M9"
    @coordinates = "40.756054,-73.986951"
    @geocode = "New York, NY"
    
    # actual conversions
    @zipcode_to_coordinates = "34.1030032,-118.4104684"
    @zipcode_to_geocode = "Beverly Hills, CA, USA"
    @postalcode_to_coordinates = "53.570447,-113.456083"
    @geocode_to_coordinates = "40.756054,-73.986951"
    @coordinates_to_geocode = "New York, NY, USA"
    
    Barometer.google_geocode_key = nil
    Barometer::Query.google_geocode_key = nil
    #Barometer.skip_graticule = true
  end
  
  describe "the class methods" do
    
    it "detects a zipcode" do
      Barometer::Query.is_us_zipcode?(@zipcode).should be_true
      Barometer::Query.is_us_zipcode?(@postal_code).should be_false
      Barometer::Query.is_us_zipcode?(@coordinates).should be_false
    end
    
    it "detects a postalcode" do
      Barometer::Query.is_canadian_postcode?(@postal_code).should be_true
      Barometer::Query.is_canadian_postcode?(@zipcode).should be_false
      Barometer::Query.is_canadian_postcode?(@coordinates).should be_false
    end
    
    it "detects a coordinates" do
      Barometer::Query.is_coordinates?(@coordinates).should be_true
      Barometer::Query.is_coordinates?(@zipcode).should be_false
      Barometer::Query.is_coordinates?(@postal_code).should be_false
    end
    
  end
  
  describe "determines the query format" do
    
    before(:each) do
      @query = Barometer::Query.new
      @query.country_code.should be_nil
    end

    it "recognizes a zip code" do
      @query.q = @zipcode
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :zipcode
      
      @query.country_code.should == "US"
      @query.zipcode?.should be_true
      @query.postalcode?.should be_false
      @query.coordinates?.should be_false
      @query.geocode?.should be_false
    end
    
    it "recognizes a postal code" do
      @query.q = @postal_code
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :postalcode
      
      @query.country_code.should == "CA"
      @query.zipcode?.should be_false
      @query.postalcode?.should be_true
      @query.coordinates?.should be_false
      @query.geocode?.should be_false
    end
    
    it "recognizes latitude/longitude" do
      @query.q = @coordinates
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :coordinates
      
      @query.country_code.should be_nil
      @query.zipcode?.should be_false
      @query.postalcode?.should be_false
      @query.coordinates?.should be_true
      @query.geocode?.should be_false
    end
    
    it "defaults to a general geo_location" do
      @query.q = @geocode
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :geocode
      
      @query.country_code.should be_nil
      @query.zipcode?.should be_false
      @query.postalcode?.should be_false
      @query.coordinates?.should be_false
      @query.geocode?.should be_true
    end
    
  end
  
  describe "when initialized" do
    
    before(:each) do
      @query = Barometer::Query.new
    end
    
    it "responds to q" do
      @query.q.should be_nil
    end
    
#    it "responds to geo" do
#      @query.geo.should be_nil
#    end
    
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
      Barometer::Query.google_geocode_key.should be_nil
    end
    
    it "sets the google_api_key" do
      key = "KEY"
      Barometer::Query.google_geocode_key = key
      Barometer::Query.google_geocode_key.should == key
    end
    
    it "defaults to the Module geocode key" do
      key = "KEY"
      Barometer::Query.google_geocode_key.should be_nil
      Barometer.google_geocode_key = key
      Barometer::Query.google_geocode_key.should == key
    end
    
    it "responds to preferred" do
      @query.preferred.should be_nil
    end
    
    it "responds to geo" do
      @query.geo.should be_nil
    end
    
  end
  
  use_graticule = true
  
  if use_graticule
  describe "when converting queries" do
    
    before(:each) do
      @key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
      url_start = "http://maps.google.com/maps/geo?"
      #
      # for Graticule and/or HTTParty geocoding
      #
      FakeWeb.register_uri(:get, 
        "#{url_start}gl=US&key=#{@key}&output=xml&q=90210",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'geocode_90210.xml')
        )
      )
      FakeWeb.register_uri(:get, 
        "#{url_start}gl=CA&key=#{@key}&output=xml&q=T5B%204M9",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'geocode_T5B4M9.xml')
        )
      )
      #
      # for Graticule geocoding
      #
      FakeWeb.register_uri(:get, 
        "#{url_start}gl=&key=#{@key}&output=xml&q=New%20York,%20NY",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'geocode_newyork_ny.xml')
        )
      )
      FakeWeb.register_uri(:get, 
        "#{url_start}gl=&key=#{@key}&output=xml&q=40.756054,-73.986951",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'geocode_40_73.xml')
        )
      )
      #
      # for HTTParty geocoding
      #
      FakeWeb.register_uri(:get, 
        "#{url_start}output=xml&q=New%20York%2C%20NY&gl=&key=#{@key}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'geocode_newyork_ny.xml')
        )
      )
      FakeWeb.register_uri(:get, 
        "#{url_start}gl=&output=xml&q=#{CGI.escape("40.756054,-73.986951")}&key=#{@key}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'geocode_40_73.xml')
        )
      )
    end

    describe "to coordinates," do
      
      before(:each) do
        Barometer::Query.google_geocode_key = @key
      end

      it "skips conversion unless Graticule enabled or no API key" do
        Barometer::Query.google_geocode_key = nil
        Barometer::Query.google_geocode_key.should be_nil
        Barometer.google_geocode_key = nil
        Barometer.google_geocode_key.should be_nil
        Barometer::Query.to_coordinates(@geocode, :geocode).should be_nil
      end
      
      it "attempts conversion if Graticule enabled and has API key" do
        Barometer::Query.to_coordinates(@geocode, :geocode).should_not be_nil
      end
      
      it "converts from geocode" do
        Barometer::Query.to_coordinates(@geocode, :geocode).first.should == "40.756054,-73.986951"
      end
      
      it "converts from zipcode" do
        Barometer::Query.to_coordinates(@zipcode, :zipcode).first.should == "34.1030032,-118.4104684"
      end
      
      it "converts from postalcode" do
        Barometer::Query.to_coordinates(@postal_code, :postalcode).first.should == "53.570447,-113.456083"
      end
      
    end
    
    describe "to geocode" do
      
      before(:each) do
        Barometer::Query.google_geocode_key = @key
      end
      
      describe "when Graticule enabled," do
        
        it "converts from coordinates" do
          Barometer::Query.to_geocode(@coordinates, :coordinates).first.should == "New York, NY, USA"
        end

        it "converts from zipcode" do
          Barometer::Query.to_geocode(@zipcode, :zipcode).first.should == "Beverly Hills, CA, USA"
        end

        it "converts from postalcode" do
          Barometer::Query.to_geocode(@postal_code, :postalcode).first.should == @postal_code
        end
        
      end
      
      describe "when Graticule disabled," do
        
        it "uses coordinates" do
          Barometer::Query.google_geocode_key = nil
          Barometer::Query.google_geocode_key.should be_nil
          Barometer.google_geocode_key = nil
          Barometer.google_geocode_key.should be_nil
          Barometer::Query.to_geocode(@coordinates, :coordinates).first.should == @coordinates
        end

        it "uses zipcode" do
          Barometer::Query.google_geocode_key = nil
          Barometer::Query.google_geocode_key.should be_nil
          Barometer.google_geocode_key = nil
          Barometer.google_geocode_key.should be_nil
          Barometer::Query.to_geocode(@zipcode, :zipcode).first.should == @zipcode
        end

        it "uses postalcode" do
          Barometer::Query.google_geocode_key = nil
          Barometer::Query.google_geocode_key.should be_nil
          Barometer.google_geocode_key = nil
          Barometer.google_geocode_key.should be_nil
          Barometer::Query.to_geocode(@postal_code, :postalcode).first.should == @postal_code
        end
        
      end
      
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
    
    describe "and the query is already of an acceptable format" do
      
      before(:each) do
        # all formats accepted
        @acceptable_formats = [:zipcode, :postalcode, :geocode, :coordinates]
      end
      
      it "returns the zipcode untouched" do
        query = Barometer::Query.new(@zipcode)
        query.convert!(@acceptable_formats).should == @zipcode
        query.country_code.should == "US"
      end
      
      it "returns the postalcode untouched" do
        query = Barometer::Query.new(@postal_code)
        query.convert!(@acceptable_formats).should == @postal_code
        query.country_code.should == "CA"
      end
      
      it "returns the coordinates untouched" do
        query = Barometer::Query.new(@coordinates)
        query.convert!(@acceptable_formats).should == @coordinates
      end
      
      it "returns the geocode untouched" do
        query = Barometer::Query.new(@geocode)
        query.convert!(@acceptable_formats).should == @geocode
      end
      
    end
    
    describe "and the query needs converting" do
      
      describe "with an intial format of :zipcode," do
        
        before(:each) do
          @query = Barometer::Query.new(@zipcode)
          Barometer::Query.google_geocode_key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          @query.convert!(acceptable_formats).should == @zipcode_to_coordinates
          @query.country_code.should == "US"
        end
        
        it "converts to geocode" do
          acceptable_formats = [:geocode]
          @query.convert!(acceptable_formats).should == @zipcode_to_geocode
          @query.country_code.should == "US"
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          @query.convert!(acceptable_formats).should be_nil
          @query.country_code.should == "US"
        end
        
      end
      
      describe "with an intial format of :postalcode," do
        
        before(:each) do
          @query = Barometer::Query.new(@postal_code)
          Barometer::Query.google_geocode_key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          @query.convert!(acceptable_formats).should == @postalcode_to_coordinates
          @query.country_code.should == "CA"
        end
        
        it "skips converting to geocode" do
          acceptable_formats = [:geocode]
          @query.convert!(acceptable_formats).should == @postal_code
          @query.country_code.should == "CA"
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          @query.convert!(acceptable_formats).should be_nil
          @query.country_code.should == "CA"
        end
        
      end
      
      describe "with an intial format of :geocode," do
        
        before(:each) do
          @query = Barometer::Query.new(@geocode)
          Barometer::Query.google_geocode_key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          @query.convert!(acceptable_formats).should == @geocode_to_coordinates
          @query.country_code.should == "US"
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          @query.convert!(acceptable_formats).should be_nil
          @query.country_code.should be_nil
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          @query.convert!(acceptable_formats).should be_nil
          @query.country_code.should be_nil
        end
        
      end
      
      describe "with an intial format of :coordinates," do
        
        before(:each) do
          @query = Barometer::Query.new(@coordinates)
          Barometer::Query.google_geocode_key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
        end
        
        it "converts to geocode" do
          acceptable_formats = [:geocode]
          @query.convert!(acceptable_formats).should == @coordinates_to_geocode
          @query.country_code.should == "US"
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          @query.convert!(acceptable_formats).should be_nil
          @query.country_code.should be_nil
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          @query.convert!(acceptable_formats).should be_nil
          @query.country_code.should be_nil
        end
        
      end
      
    end
    
  end
  end
  
end