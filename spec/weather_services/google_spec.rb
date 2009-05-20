require 'spec_helper'
include Barometer

describe "Google" do
  
  before(:each) do
    @accepted_formats = [:zipcode, :postalcode, :geocode]
    @base_uri = "http://google.com"
  end
  
  describe "the class methods" do
    
    it "defines accepted_formats" do
      WeatherService::Google._accepted_formats.should == @accepted_formats
    end
    
    it "defines source_name" do
      WeatherService::Google._source_name.should == :google
    end
    
    # it "defines base_uri" do
    #   Barometer::Google.base_uri.should == @base_uri
    # end
    
    it "defines get_all" do
      WeatherService::Google.respond_to?("_fetch").should be_true
    end
    
  end
  
  describe "building the current data" do
    
    it "defines the build method" do
      WeatherService::Google.respond_to?("_build_current").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::Google._build_current }.should raise_error(ArgumentError)
      lambda { WeatherService::Google._build_current({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Measurement::Current object" do
      current = WeatherService::Google._build_current({})
      current.is_a?(Measurement::Result).should be_true
    end
    
  end
  
  describe "building the forecast data" do
    
    it "defines the build method" do
      WeatherService::Google.respond_to?("_build_forecast").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::Google._build_forecast }.should raise_error(ArgumentError)
      lambda { WeatherService::Google._build_forecast({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Array object" do
      current = WeatherService::Google._build_forecast({})
      current.is_a?(Measurement::ResultArray).should be_true
    end
    
  end
  
  describe "building the location data" do
    
    it "defines the build method" do
      WeatherService::Google.respond_to?("_build_location").should be_true
    end
    
    it "requires Barometer::Geo input" do
      geo = Data::Geo.new({})
      lambda { WeatherService::Google._build_location(nil,{}) }.should raise_error(ArgumentError)
      lambda { WeatherService::Google._build_location(nil,geo) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Location object" do
      geo = Data::Geo.new({})
      location = WeatherService::Google._build_location(nil,geo)
      location.is_a?(Data::Location).should be_true
    end
    
  end

  # describe "building the timezone" do
  #   
  #   it "defines the build method" do
  #     Barometer::Google.respond_to?("build_timezone").should be_true
  #   end
  #   
  #   it "requires Hash input" do
  #     lambda { Barometer::Google.build_timezone }.should raise_error(ArgumentError)
  #     lambda { Barometer::Google.build_timezone({}) }.should_not raise_error(ArgumentError)
  #   end
  #   
  # end
  
  describe "when measuring" do
  
    before(:each) do
      @query = Barometer::Query.new("Calgary,AB")
      @measurement = Barometer::Measurement.new
      
      FakeWeb.register_uri(:get, 
        "http://google.com/ig/api?weather=#{CGI.escape(@query.q)}&hl=en-GB",
        :string => File.read(File.join(File.dirname(__FILE__), 
          '../fixtures/services/google', 
          'calgary_ab.xml')
        )
      )  
    end
    
    describe "all" do
      
      it "responds to _measure" do
        Barometer::WeatherService::Google.respond_to?("_measure").should be_true
      end
      
      it "requires a Barometer::Measurement object" do
        lambda { Barometer::WeatherService::Google._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { Barometer::WeatherService::Google._measure("invalid", @query) }.should raise_error(ArgumentError)

        lambda { Barometer::WeatherService::Google._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
  
      it "requires a Barometer::Query query" do
        lambda { Barometer::WeatherService::Google._measure }.should raise_error(ArgumentError)
        lambda { Barometer::WeatherService::Google._measure(@measurement, 1) }.should raise_error(ArgumentError)
        
        lambda { Barometer::WeatherService::Google._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Measurement object" do
        result = Barometer::WeatherService::Google._measure(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Measurement::Result).should be_true
        result.forecast.is_a?(Measurement::ResultArray).should be_true
      end
      
    end
  
  end
  
  # describe "overall data correctness" do
  #   
  #   before(:each) do
  #     @query = Barometer::Query.new("Calgary,AB")
  #     @query.preferred = "Calgary,AB"
  #     @measurement = Barometer::Measurement.new
  #     
  #     FakeWeb.register_uri(:get, 
  #       "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape(@query.preferred)}",
  #       :string => File.read(File.join(File.dirname(__FILE__), 
  #         'fixtures', 
  #         'current_calgary_ab.xml')
  #       )
  #     )  
  #     FakeWeb.register_uri(:get, 
  #       "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape(@query.preferred)}",
  #       :string => File.read(File.join(File.dirname(__FILE__), 
  #         'fixtures', 
  #         'forecast_calgary_ab.xml')
  #       )
  #     )
  #   end
  # 
  #  # TODO: complete this
  #  it "should correctly build the data" do
  #     result = Barometer::Wunderground._measure(@measurement, @query)
  #     
  #     # build timezone
  #     @measurement.timezone.timezone.should == "America/Edmonton"
  #     
  #     time = Time.local(2009, 4, 23, 18, 00, 0)
  #     rise = Time.local(time.year, time.month, time.day, 6, 23)
  #     set = Time.local(time.year, time.month, time.day, 20, 45)
  #     sun_rise = @measurement.timezone.tz.local_to_utc(rise)
  #     sun_set = @measurement.timezone.tz.local_to_utc(set)
  #     
  #     # build current
  #     @measurement.current.sun.rise.should == sun_rise
  #     @measurement.current.sun.set.should == sun_set
  #   end
  #   
  # end
  
end