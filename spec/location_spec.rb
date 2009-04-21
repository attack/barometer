require 'spec_helper'

describe "Location" do
  
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
  end
  
  describe "the class methods" do
    
    it "detects a zipcode" do
      Barometer::Location.is_zipcode?(@zipcode).should be_true
      Barometer::Location.is_zipcode?(@postal_code).should be_false
      Barometer::Location.is_zipcode?(@coordinates).should be_false
    end
    
    it "detects a postalcode" do
      Barometer::Location.is_canadian_postcode?(@postal_code).should be_true
      Barometer::Location.is_canadian_postcode?(@zipcode).should be_false
      Barometer::Location.is_canadian_postcode?(@coordinates).should be_false
    end
    
    it "detects a coordinates" do
      Barometer::Location.is_coordinates?(@coordinates).should be_true
      Barometer::Location.is_coordinates?(@zipcode).should be_false
      Barometer::Location.is_coordinates?(@postal_code).should be_false
    end
    
  end
  
  describe "determines the query format" do
    
    before(:each) do
      @location = Barometer::Location.new
    end

    it "recognizes a zip code" do
      @location.query = @zipcode
      @location.format.should be_nil
      @location.determine_format!
      @location.format.to_sym.should == :zipcode
      
      @location.zipcode?.should be_true
      @location.postalcode?.should be_false
      @location.coordinates?.should be_false
      @location.geocode?.should be_false
    end
    
    it "recognizes a postal code" do
      @location.query = @postal_code
      @location.format.should be_nil
      @location.determine_format!
      @location.format.to_sym.should == :postalcode
      
      @location.zipcode?.should be_false
      @location.postalcode?.should be_true
      @location.coordinates?.should be_false
      @location.geocode?.should be_false
    end
    
    it "recognizes latitude/longitude" do
      @location.query = @coordinates
      @location.format.should be_nil
      @location.determine_format!
      @location.format.to_sym.should == :coordinates
      
      @location.zipcode?.should be_false
      @location.postalcode?.should be_false
      @location.coordinates?.should be_true
      @location.geocode?.should be_false
    end
    
    it "defaults to a general geo_location" do
      @location.query = @geocode
      @location.format.should be_nil
      @location.determine_format!
      @location.format.to_sym.should == :geocode
      
      @location.zipcode?.should be_false
      @location.postalcode?.should be_false
      @location.coordinates?.should be_false
      @location.geocode?.should be_true
    end
    
  end
  
  describe "when initialized" do
    
    before(:each) do
      @location = Barometer::Location.new
    end
    
    it "responds to query" do
      @location.query.should be_nil
    end
    
    it "responds to preffered_query" do
      @location.preffered_query.should be_nil
    end
    
    it "responds to format" do
      @location.format.should be_nil
    end
    
    it "sets the query" do
      location = Barometer::Location.new(@geocode)
      location.query.should == @geocode
    end
    
    it "determines the format" do
      location = Barometer::Location.new(@geocode)
      location.format.should_not be_nil
    end
    
    it "responds to google_api_key" do
      Barometer::Location.google_api_key.should be_nil
    end
    
    it "sets the google_api_key" do
      key = "KEY"
      Barometer::Location.google_api_key = key
      Barometer::Location.google_api_key.should == key
    end
    
  end
  
  describe "when converting queries" do
    
    describe "to coordinates," do
      
      before(:each) do
        Barometer::Location.google_api_key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
      end

      it "skips conversion unless Graticule enabled or no API key" do
        Barometer::Location.google_api_key = nil
        Barometer::Location.google_api_key.should be_nil
        Barometer::Location.to_coordinates(@geocode, :geocode).should be_nil
      end
      
      it "attempts conversion if Graticule enabled and has API key" do
        Barometer::Location.to_coordinates(@geocode, :geocode).should_not be_nil
      end
      
      it "converts from geocode" do
        Barometer::Location.to_coordinates(@geocode, :geocode).should == "40.756054,-73.986951"
      end
      
      it "converts from zipcode" do
        Barometer::Location.to_coordinates(@zipcode, :zipcode).should == "34.1030032,-118.4104684"
      end
      
      it "converts from postalcode" do
        Barometer::Location.to_coordinates(@postal_code, :postalcode).should == "53.570447,-113.456083"
      end
      
    end
    
    describe "to geocode" do
      
      describe "when Graticule enabled," do
        
        it "converts from coordinates" do
          Barometer::Location.to_geocode(@coordinates, :coordinates).should == "New York, NY, USA"
        end

        it "converts from zipcode" do
          Barometer::Location.to_geocode(@zipcode, :zipcode).should == "Beverly Hills, CA, USA"
        end

        it "converts from postalcode" do
          Barometer::Location.to_geocode(@postal_code, :postalcode).should == @postal_code
        end
        
      end
      
      describe "when Graticule disabled," do
        
        it "uses coordinates" do
          Barometer::Location.google_api_key = nil
          Barometer::Location.google_api_key.should be_nil
          Barometer::Location.to_geocode(@coordinates, :coordinates).should == @coordinates
        end

        it "uses zipcode" do
          Barometer::Location.google_api_key = nil
          Barometer::Location.google_api_key.should be_nil
          Barometer::Location.to_geocode(@zipcode, :zipcode).should == @zipcode
        end

        it "uses postalcode" do
          Barometer::Location.google_api_key = nil
          Barometer::Location.google_api_key.should be_nil
          Barometer::Location.to_geocode(@postal_code, :postalcode).should == @postal_code
        end
        
      end
      
    end
    
  end
  
  describe "when returning the query to a Weather API" do
    
    it "raises an error if there are NO acceptable formats" do
      acceptable_formats = nil
      location = Barometer::Location.new
      lambda { location.convert_query!(acceptable_formats) }.should raise_error
      
      acceptable_formats = []
      lambda { location.convert_query!(acceptable_formats) }.should raise_error
    end
    
    describe "and the query is already of an acceptable format" do
      
      before(:each) do
        # all formats accepted
        @acceptable_formats = [:zipcode, :postalcode, :geocode, :coordinates]
      end
      
      it "returns the zipcode untouched" do
        location = Barometer::Location.new(@zipcode)
        location.convert_query!(@acceptable_formats).should == @zipcode
      end
      
      it "returns the postalcode untouched" do
        location = Barometer::Location.new(@postal_code)
        location.convert_query!(@acceptable_formats).should == @postal_code
      end
      
      it "returns the coordinates untouched" do
        location = Barometer::Location.new(@coordinates)
        location.convert_query!(@acceptable_formats).should == @coordinates
      end
      
      it "returns the geocode untouched" do
        location = Barometer::Location.new(@geocode)
        location.convert_query!(@acceptable_formats).should == @geocode
      end
      
    end
    
    describe "and the query needs converting" do
      
      describe "with an intial format of :zipcode," do
        
        before(:each) do
          @location = Barometer::Location.new(@zipcode)
          Barometer::Location.google_api_key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          @location.convert_query!(acceptable_formats).should == @zipcode_to_coordinates
        end
        
        it "converts to geocode" do
          acceptable_formats = [:geocode]
          @location.convert_query!(acceptable_formats).should == @zipcode_to_geocode
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          @location.convert_query!(acceptable_formats).should be_nil
        end
        
      end
      
      describe "with an intial format of :postalcode," do
        
        before(:each) do
          @location = Barometer::Location.new(@postal_code)
          Barometer::Location.google_api_key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          @location.convert_query!(acceptable_formats).should == @postalcode_to_coordinates
        end
        
        it "skips converting to geocode" do
          acceptable_formats = [:geocode]
          @location.convert_query!(acceptable_formats).should == @postal_code
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          @location.convert_query!(acceptable_formats).should be_nil
        end
        
      end
      
      describe "with an intial format of :geocode," do
        
        before(:each) do
          @location = Barometer::Location.new(@geocode)
          Barometer::Location.google_api_key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
        end
        
        it "converts to coordinates" do
          acceptable_formats = [:coordinates]
          @location.convert_query!(acceptable_formats).should == @geocode_to_coordinates
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          @location.convert_query!(acceptable_formats).should be_nil
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          @location.convert_query!(acceptable_formats).should be_nil
        end
        
      end
      
      describe "with an intial format of :coordinates," do
        
        before(:each) do
          @location = Barometer::Location.new(@coordinates)
          Barometer::Location.google_api_key = "ABQIAAAAq8TH4offRcGrok8JVY_MyxRi_j0U6kJrkFvY4-OX2XYmEAa76BSFwMlSow1YgX8BOPUeve_shMG7xw"
        end
        
        it "converts to geocode" do
          acceptable_formats = [:geocode]
          @location.convert_query!(acceptable_formats).should == @coordinates_to_geocode
        end
        
        it "skips converting to zipcode" do
          acceptable_formats = [:zipcode]
          @location.convert_query!(acceptable_formats).should be_nil
        end
        
        it "skips converting to postalcode" do
          acceptable_formats = [:postalcode]
          @location.convert_query!(acceptable_formats).should be_nil
        end
        
      end
      
    end
    
  end
  
end