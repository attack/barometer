require 'spec_helper'

describe "Yahoo" do
  
  before(:each) do
    @accepted_formats = [:zipcode]
    #@base_uri = "http://google.com"
  end
  
  describe "the class methods" do
    
    it "defines accepted_formats" do
      Barometer::Yahoo.accepted_formats.should == @accepted_formats
    end
    
    # it "defines base_uri" do
    #   Barometer::Google.base_uri.should == @base_uri
    # end
    
    it "defines get_all" do
      Barometer::Yahoo.respond_to?("get_all").should be_true
    end
    
  end
  
  describe "building the current data" do
    
    it "defines the build method" do
      Barometer::Yahoo.respond_to?("build_current").should be_true
    end
    
    it "requires Hash input" do
      lambda { Barometer::Yahoo.build_current }.should raise_error(ArgumentError)
      lambda { Barometer::Yahoo.build_current({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::CurrentMeasurement object" do
      current = Barometer::Yahoo.build_current({})
      current.is_a?(Barometer::CurrentMeasurement).should be_true
    end
    
  end
  
  describe "building the forecast data" do
    
    it "defines the build method" do
      Barometer::Yahoo.respond_to?("build_forecast").should be_true
    end
    
    it "requires Hash input" do
      lambda { Barometer::Yahoo.build_forecast }.should raise_error(ArgumentError)
      lambda { Barometer::Yahoo.build_forecast({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Array object" do
      current = Barometer::Yahoo.build_forecast({})
      current.is_a?(Array).should be_true
    end
    
  end
  
  describe "building the location data" do
    
    it "defines the build method" do
      Barometer::Yahoo.respond_to?("build_location").should be_true
    end
    
    it "requires Hash input" do
      lambda { Barometer::Yahoo.build_location }.should raise_error(ArgumentError)
      lambda { Barometer::Yahoo.build_location({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Location object" do
      location = Barometer::Yahoo.build_location({})
      location.is_a?(Barometer::Location).should be_true
    end
    
  end

  # describe "building the timezone" do
  #   
  #   it "defines the build method" do
  #     Barometer::Yahoo.respond_to?("build_timezone").should be_true
  #   end
  #   
  #   it "requires Hash input" do
  #     lambda { Barometer::Yahoo.build_timezone }.should raise_error(ArgumentError)
  #     lambda { Barometer::Yahoo.build_timezone({}) }.should_not raise_error(ArgumentError)
  #   end
  #   
  # end
  
  describe "when measuring" do
  
    before(:each) do
      @query = "90210"
      @measurement = Barometer::Measurement.new
      
      FakeWeb.register_uri(:get, 
        "http://weather.yahooapis.com:80/forecastrss?u=c&p=#{CGI.escape(@query)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'yahoo_90210.xml')
        )
      )  
    end
    
    describe "all" do
      
      it "responds to _measure" do
        Barometer::Yahoo.respond_to?("_measure").should be_true
      end
      
      it "requires a Barometer::Measurement object" do
        lambda { Barometer::Yahoo._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { Barometer::Yahoo._measure("invlaid", @query) }.should raise_error(ArgumentError)
  
        lambda { Barometer::Yahoo._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
  
      it "requires a String query" do
        lambda { Barometer::Yahoo._measure }.should raise_error(ArgumentError)
        lambda { Barometer::Yahoo._measure(@measurement, 1) }.should raise_error(ArgumentError)
        
        lambda { Barometer::Yahoo._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Measurement object" do
        result = Barometer::Yahoo._measure(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Barometer::CurrentMeasurement).should be_true
        result.forecast.is_a?(Array).should be_true
        
        result.source.should == :yahoo
      end
      
    end
  
  end
  
end