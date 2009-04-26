require 'spec_helper'

describe "Google" do
  
  before(:each) do
    @accepted_formats = [:zipcode, :postalcode, :geocode]
    @base_uri = "http://google.com"
  end
  
  describe "the class methods" do
    
    it "defines accepted_formats" do
      Barometer::Google.accepted_formats.should == @accepted_formats
    end
    
    # it "defines base_uri" do
    #   Barometer::Google.base_uri.should == @base_uri
    # end
    
    it "defines get_current" do
      Barometer::Google.respond_to?("get_current").should be_true
    end
    
    it "defines get_forecast" do
      Barometer::Google.respond_to?("get_forecast").should be_true
    end
    
  end
  
  describe "building the current data" do
    
    it "defines the build method" do
      Barometer::Wunderground.respond_to?("build_current").should be_true
    end
    
    it "requires Hash input" do
      lambda { Barometer::Wunderground.build_current }.should raise_error(ArgumentError)
      lambda { Barometer::Wunderground.build_current({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::CurrentMeasurement object" do
      current = Barometer::Wunderground.build_current({})
      current.is_a?(Barometer::CurrentMeasurement).should be_true
    end
    
  end
  
  describe "building the forecast data" do
    
    it "defines the build method" do
      Barometer::Wunderground.respond_to?("build_forecast").should be_true
    end
    
    it "requires Hash input" do
      lambda { Barometer::Wunderground.build_forecast }.should raise_error(ArgumentError)
      lambda { Barometer::Wunderground.build_forecast({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Array object" do
      current = Barometer::Wunderground.build_forecast({})
      current.is_a?(Array).should be_true
    end
    
  end

  # describe "building the timezone" do
  #   
  #   it "defines the build method" do
  #     Barometer::Wunderground.respond_to?("build_timezone").should be_true
  #   end
  #   
  #   it "requires Hash input" do
  #     lambda { Barometer::Wunderground.build_timezone }.should raise_error(ArgumentError)
  #     lambda { Barometer::Wunderground.build_timezone({}) }.should_not raise_error(ArgumentError)
  #   end
  #   
  # end
  
  describe "when measuring" do
  
    before(:each) do
      @query = "Calgary,AB"
      @measurement = Barometer::Measurement.new
      
      FakeWeb.register_uri(:get, 
        "http://google.com/ig/api?weather=#{CGI.escape(@query)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'google_calgary_ab.xml')
        )
      )  
    end
    
    describe "all" do
      
      it "responds to _measure" do
        Barometer::Google.respond_to?("_measure").should be_true
      end
      
      it "requires a Barometer::Measurement object" do
        lambda { Barometer::Google._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { Barometer::Google._measure("invlaid", @query) }.should raise_error(ArgumentError)
  
        lambda { Barometer::Google._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
  
      it "requires a String query" do
        lambda { Barometer::Google._measure }.should raise_error(ArgumentError)
        lambda { Barometer::Google._measure(@measurement, 1) }.should raise_error(ArgumentError)
        
        lambda { Barometer::Google._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Measurement object" do
        result = Barometer::Google._measure(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Barometer::CurrentMeasurement).should be_true
        result.forecast.is_a?(Array).should be_true
        
        result.source.should == :google
      end
      
    end
  
  end
  
end