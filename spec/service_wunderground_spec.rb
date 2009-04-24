require 'spec_helper'

describe "Wunderground" do
  
  before(:each) do
    @accepted_formats = [:zipcode, :postalcode, :coordinates, :geocode]
    @base_uri = "http://api.wunderground.com/auto/wui/geo"
  end
  
  describe "the class methods" do
    
    it "defines accepted_formats" do
      Barometer::Wunderground.accepted_formats.should == @accepted_formats
    end
    
    it "defines base_uri" do
      Barometer::Wunderground.base_uri.should == @base_uri
    end
    
    it "defines get_current" do
      Barometer::Wunderground.respond_to?("get_current").should be_true
    end
    
    it "defines get_forecast" do
      Barometer::Wunderground.respond_to?("get_forecast").should be_true
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
  
  describe "building the station data" do
    
    it "defines the build method" do
      Barometer::Wunderground.respond_to?("build_station").should be_true
    end
    
    it "requires Hash input" do
      lambda { Barometer::Wunderground.build_station }.should raise_error(ArgumentError)
      lambda { Barometer::Wunderground.build_station({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Station object" do
      station = Barometer::Wunderground.build_station({})
      station.is_a?(Barometer::Station).should be_true
    end
    
  end
  
  describe "when measuring" do

    before(:each) do
      @query = "Calgary,AB"
      @measurement = Barometer::Measurement.new
      
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape(@query)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'current_calgary_ab.xml')
        )
      )  
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape(@query)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'forecast_calgary_ab.xml')
        )
      )
    end
    
    describe "all" do
      
      it "responds to measure_all" do
        Barometer::Wunderground.respond_to?("measure_all").should be_true
      end
      
      it "requires a Barometer::Measurement object" do
        lambda { Barometer::Wunderground.measure_all(nil, @query) }.should raise_error(ArgumentError)
        lambda { Barometer::Wunderground.measure_all("invlaid", @query) }.should raise_error(ArgumentError)

        lambda { Barometer::Wunderground.measure_all(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "requires a String query" do
        lambda { Barometer::Wunderground.measure_all }.should raise_error(ArgumentError)
        lambda { Barometer::Wunderground.measure_all(@measurement, 1) }.should raise_error(ArgumentError)
        
        lambda { Barometer::Wunderground.measure_all(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Measurement object" do
        result = Barometer::Wunderground.measure_all(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        
        result.source.should == :wunderground
      end
      
    end
    
    describe "current" do
      
      it "responds to measure_current" do
        Barometer::Wunderground.respond_to?("measure_current").should be_true
      end

      it "requires a Barometer::Measurement object" do
        lambda { Barometer::Wunderground.measure_current(nil, @query) }.should raise_error(ArgumentError)
        lambda { Barometer::Wunderground.measure_current("invlaid", @query) }.should raise_error(ArgumentError)

        lambda { Barometer::Wunderground.measure_current(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "requires a String object" do
        lambda { Barometer::Wunderground.measure_current(@measurement) }.should raise_error(ArgumentError)
        lambda { Barometer::Wunderground.measure_current(@measurement, 1) }.should raise_error(ArgumentError)
        
        lambda { Barometer::Wunderground.measure_current(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Measurement object" do
        result = Barometer::Wunderground.measure_current(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        
        result.source.should == :wunderground
      end

      it "returns a Barometer::Measurement object with a Barometer::CurrentMeasurement object" do
        result = Barometer::Wunderground.measure_current(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Barometer::CurrentMeasurement).should be_true
      end
      
    end
    
    describe "forecast" do
      
      it "responds to measure_forecast" do
        Barometer::Wunderground.respond_to?("measure_forecast").should be_true
      end

      it "requires a Barometer::Measurement object" do
        lambda { Barometer::Wunderground.measure_forecast(nil, @query) }.should raise_error(ArgumentError)
        lambda { Barometer::Wunderground.measure_forecast("invalid", @query) }.should raise_error(ArgumentError)

        lambda { Barometer::Wunderground.measure_forecast(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "requires a String object" do
        lambda { Barometer::Wunderground.measure_forecast(@measurement) }.should raise_error(ArgumentError)
        lambda { Barometer::Wunderground.measure_forecast(@measurement, 1) }.should raise_error(ArgumentError)
        
        lambda { Barometer::Wunderground.measure_forecast(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Measurement object" do
        result = Barometer::Wunderground.measure_forecast(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        
        result.source.should == :wunderground
      end

      it "returns a Barometer::Measurement object with an Array object" do
        result = Barometer::Wunderground.measure_forecast(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.forecast.is_a?(Array).should be_true
      end
      
    end

  end
  
end