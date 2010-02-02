require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Barometer

describe "Wunderground" do
  
  before(:each) do
    @accepted_formats = [:zipcode, :postalcode, :icao, :coordinates, :geocode]
    @base_uri = "http://api.wunderground.com/auto/wui/geo"
  end
  
  describe "the class methods" do
    
    it "defines accepted_formats" do
      WeatherService::Wunderground._accepted_formats.should == @accepted_formats
    end
    
    it "defines source_name" do
      WeatherService::Wunderground._source_name.should == :wunderground
    end
    
    it "defines fetch_current" do
      WeatherService::Wunderground.respond_to?("_fetch_current").should be_true
    end
    
    it "defines fetch_forecast" do
      WeatherService::Wunderground.respond_to?("_fetch_forecast").should be_true
    end
    
  end
  
  describe "building the current data" do
    
    it "defines the build method" do
      WeatherService::Wunderground.respond_to?("_build_current").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::Wunderground._build_current }.should raise_error(ArgumentError)
      WeatherService::Wunderground._build_current({})
      lambda { WeatherService::Wunderground._build_current({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::CurrentMeasurement object" do
      current = WeatherService::Wunderground._build_current({})
      current.is_a?(Measurement::Result).should be_true
    end
    
  end
  
  describe "building the forecast data" do
    
    it "defines the build method" do
      WeatherService::Wunderground.respond_to?("_build_forecast").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::Wunderground._build_forecast }.should raise_error(ArgumentError)
      lambda { WeatherService::Wunderground._build_forecast({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Array object" do
      current = WeatherService::Wunderground._build_forecast({})
      current.is_a?(Array).should be_true
    end
    
  end
  
  describe "building the station data" do
    
    it "defines the build method" do
      WeatherService::Wunderground.respond_to?("_build_station").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::Wunderground._build_station }.should raise_error(ArgumentError)
      lambda { WeatherService::Wunderground._build_station({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Location object" do
      station = WeatherService::Wunderground._build_station({})
      station.is_a?(Data::Location).should be_true
    end
    
  end
  
  describe "building the location data" do
    
    it "defines the build method" do
      WeatherService::Wunderground.respond_to?("_build_location").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::Wunderground._build_location }.should raise_error(ArgumentError)
      lambda { WeatherService::Wunderground._build_location({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Location object" do
      location = WeatherService::Wunderground._build_location({})
      location.is_a?(Data::Location).should be_true
    end
    
  end
  
  describe "building the timezone" do
    
    it "defines the build method" do
      WeatherService::Wunderground.respond_to?("_parse_full_timezone").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::Wunderground._parse_full_timezone }.should raise_error(ArgumentError)
      lambda { WeatherService::Wunderground._parse_full_timezone({}) }.should_not raise_error(ArgumentError)
    end
    
  end
  
  describe "building the sun data" do
       
    it "defines the build method" do
      WeatherService::Wunderground.respond_to?("_build_sun").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::Wunderground._build_sun }.should raise_error(ArgumentError)
      lambda { WeatherService::Wunderground._build_sun({}) }.should_not raise_error(ArgumentError)
    end
    
    it "requires Barometer::Zone input" do
      lambda { WeatherService::Wunderground._build_sun({}, "invalid") }.should raise_error(ArgumentError)
      lambda { WeatherService::Wunderground._build_sun({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Sun object" do
      sun = WeatherService::Wunderground._build_sun({})
      sun.is_a?(Data::Sun).should be_true
    end
    
  end
  
  describe "when measuring" do

    before(:each) do
      @query = Barometer::Query.new("Calgary,AB")
      @measurement = Barometer::Measurement.new
      
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape(@query.q)}",
        :body => File.read(File.join(File.dirname(__FILE__), 
          '../fixtures/services/wunderground',
          'current_calgary_ab.xml')
        )
      )  
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape(@query.q)}",
        :body => File.read(File.join(File.dirname(__FILE__), 
          '../fixtures/services/wunderground',
          'forecast_calgary_ab.xml')
        )
      )
    end
    
    describe "all" do
      
      it "responds to _measure" do
        WeatherService::Wunderground.respond_to?("_measure").should be_true
      end
      
      it "requires a Barometer::Measurement object" do
        lambda { WeatherService::Wunderground._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { WeatherService::Wunderground._measure("invlaid", @query) }.should raise_error(ArgumentError)

        lambda { WeatherService::Wunderground._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "requires a Barometer::Query query" do
        lambda { WeatherService::Wunderground._measure }.should raise_error(ArgumentError)
        lambda { WeatherService::Wunderground._measure(@measurement, 1) }.should raise_error(ArgumentError)
        
        lambda { WeatherService::Wunderground._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Measurement object" do
        result = WeatherService::Wunderground._measure(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Measurement::Result).should be_true
        result.forecast.is_a?(Array).should be_true
      end
      
    end

  end
  
  describe "overall data correctness" do
    
    before(:each) do
      @query = Barometer::Query.new("Calgary,AB")
      @measurement = Barometer::Measurement.new
      
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape(@query.q)}",
        :body => File.read(File.join(File.dirname(__FILE__), 
          '../fixtures/services/wunderground',
          'current_calgary_ab.xml')
        )
      )  
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape(@query.q)}",
        :body => File.read(File.join(File.dirname(__FILE__), 
          '../fixtures/services/wunderground',
          'forecast_calgary_ab.xml')
        )
      )
    end

   # TODO: complete this
   it "should correctly build the data" do
      result = WeatherService::Wunderground._measure(@measurement, @query)
      
      # build timezone
      @measurement.timezone.zone_full.should == "America/Edmonton"
      @measurement.timezone.current.should == "America/Edmonton"
      
      # time = Time.local(2009, 4, 23, 18, 00, 0)
      # rise = Time.local(time.year, time.month, time.day, 6, 23)
      # set = Time.local(time.year, time.month, time.day, 20, 45)
      # sun_rise = @measurement.timezone.tz.local_to_utc(rise)
      # sun_set = @measurement.timezone.tz.local_to_utc(set)
      
      # build current
      #@measurement.current.sun.rise.should == sun_rise
      #@measurement.current.sun.set.should == sun_set
      @measurement.current.sun.rise.to_s.should == "06:23 am"
      @measurement.current.sun.set.to_s.should == "08:45 pm"
    end
    
  end
  
end