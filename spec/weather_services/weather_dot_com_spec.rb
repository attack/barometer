require 'spec_helper'
include Barometer

describe "WeatherDotCom" do
  
  before(:each) do
    @accepted_formats = [:short_zipcode, :weather_id]
  end
  
  describe "the class methods" do
    
    it "defines accepted_formats" do
      WeatherService::WeatherDotCom._accepted_formats.should == @accepted_formats
    end
    
    it "defines source_name" do
      WeatherService::WeatherDotCom._source_name.should == :weather_dot_com
    end
    
    it "defines get_all" do
      WeatherService::WeatherDotCom.respond_to?("_fetch").should be_true
    end
    
    it "defines _requires_keys?" do
      WeatherService::WeatherDotCom.respond_to?("_requires_keys?").should be_true
      WeatherService::WeatherDotCom._requires_keys?.should be_true
    end
    
    it "defines _has_keys?" do
      WeatherService::WeatherDotCom.respond_to?("_has_keys?").should be_true
      WeatherService::WeatherDotCom._has_keys?.should be_false
      WeatherService::WeatherDotCom.keys = { :partner => WEATHER_PARTNER_KEY, :license => WEATHER_LICENSE_KEY }
      WeatherService::WeatherDotCom._has_keys?.should be_true
    end
    
  end
  
  describe "building the current data" do
    
    it "defines the build method" do
      WeatherService::WeatherDotCom.respond_to?("_build_current").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::WeatherDotCom._build_current }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_current({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Measurement::Current object" do
      current = WeatherService::WeatherDotCom._build_current({})
      current.is_a?(Measurement::Current).should be_true
    end
    
  end
  
  describe "building the forecast data" do
    
    it "defines the build method" do
      WeatherService::WeatherDotCom.respond_to?("_build_forecast").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::WeatherDotCom._build_forecast }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_forecast({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Array object" do
      current = WeatherService::WeatherDotCom._build_forecast({})
      current.is_a?(Array).should be_true
    end
    
  end
  
  describe "building the location data" do
    
    it "defines the build method" do
      WeatherService::WeatherDotCom.respond_to?("_build_location").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::WeatherDotCom._build_location }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_location({}) }.should_not raise_error(ArgumentError)
    end
    
    it "requires Barometer::Geo input" do
      geo = Data::Geo.new({})
      lambda { WeatherService::WeatherDotCom._build_location({}, {}) }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_location({}, geo) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Location object" do
      location = WeatherService::WeatherDotCom._build_location({})
      location.is_a?(Data::Location).should be_true
    end
    
  end
  
  describe "building the sun data" do
    
    it "defines the build method" do
      WeatherService::WeatherDotCom.respond_to?("_build_sun").should be_true
    end
    
    it "requires Hash input" do
      lambda { WeatherService::WeatherDotCom._build_sun }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_sun({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Sun object" do
      sun = WeatherService::WeatherDotCom._build_sun({})
      sun.is_a?(Data::Sun).should be_true
    end
    
  end

  describe "when measuring" do

    before(:each) do
      @query = Barometer::Query.new("90210")
      @measurement = Barometer::Measurement.new
      
      url = "http://xoap.weather.com:80/weather/local/"
  
      FakeWeb.register_uri(:get, 
         "#{url}90210?dayf=5&unit=m&link=xoap&par=#{WEATHER_PARTNER_KEY}&prod=xoap&key=#{WEATHER_LICENSE_KEY}&cc=*",
         :string => File.read(File.join(File.dirname(__FILE__), 
           '../fixtures/services/weather_dot_com', 
           '90210.xml')
         )
       )  
    end

    describe "all" do
      
      it "responds to _measure" do
        WeatherService::WeatherDotCom.respond_to?("_measure").should be_true
      end
      
      it "requires a Barometer::Measurement object" do
        lambda { WeatherService::WeatherDotCom._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { WeatherService::WeatherDotCom._measure("invalid", @query) }.should raise_error(ArgumentError)

        lambda { WeatherService::WeatherDotCom._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
  
      it "requires a Barometer::Query query" do
        lambda { WeatherService::WeatherDotCom._measure }.should raise_error(ArgumentError)
        lambda { WeatherService::WeatherDotCom._measure(@measurement, 1) }.should raise_error(ArgumentError)
        
        lambda { WeatherService::WeatherDotCom._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Measurement object" do
        result = WeatherService::WeatherDotCom._measure(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Measurement::Current).should be_true
        result.forecast.is_a?(Measurement::ForecastArray).should be_true
      end
      
    end

  end
  
  describe "overall data correctness" do
    
    before(:each) do
      @query = Barometer::Query.new("90210")
      @measurement = Barometer::Measurement.new
      
      url = "http://xoap.weather.com:80/weather/local/"
  
      FakeWeb.register_uri(:get, 
         "#{url}90210?dayf=5&unit=m&link=xoap&par=#{WEATHER_PARTNER_KEY}&prod=xoap&key=#{WEATHER_LICENSE_KEY}&cc=*",
         :string => File.read(File.join(File.dirname(__FILE__), 
           '../fixtures/services/weather_dot_com', 
           '90210.xml')
         )
       )
    end
    
    it "should correctly build the data" do
      result = WeatherService::WeatherDotCom._measure(@measurement, @query)
      
      # build current
      @measurement.current.humidity.to_i.should == 75
      @measurement.current.icon.should == "33"
      @measurement.current.condition.should == "Fair"
      @measurement.current.temperature.to_i.should == 16
      @measurement.current.dew_point.to_i.should == 12
      @measurement.current.wind_chill.to_i.should == 16
      @measurement.current.wind.to_i.should == 5
      @measurement.current.wind.degrees.to_i.should == 80
      @measurement.current.wind.direction.should == "E"
      @measurement.current.pressure.to_f.should == 1016.6
      @measurement.current.visibility.to_f.should == 16.1
      
      # build sun
      # sun_rise = Barometer::Zone.merge("6:01 am", "5/4/09 12:51 AM PDT", -7)
      # sun_set = Barometer::Zone.merge("7:40 pm", "5/4/09 12:51 AM PDT", -7)
      # @measurement.current.sun.rise.should == sun_rise
      # @measurement.current.sun.set.should == sun_set
      @measurement.current.sun.rise.to_s.should == "06:01 am"
      @measurement.current.sun.set.to_s.should == "07:40 pm"

      # builds location
      @measurement.location.name.should == "Beverly Hills, CA (90210)"
      @measurement.location.latitude.to_f.should == 34.10
      @measurement.location.longitude.to_f.should == -118.41
      
      # builds forecasts
      @measurement.forecast.size.should == 5

      @measurement.forecast[0].date.should == Date.parse("May 3")
      @measurement.forecast[0].condition.should == "Partly Cloudy"
      @measurement.forecast[0].icon.should == "30"
      @measurement.forecast[0].high.should be_nil
      @measurement.forecast[0].low.to_i.should == 14
      @measurement.forecast[0].pop.to_i.should == 10
      @measurement.forecast[0].humidity.to_i.should == 65
      
      @measurement.forecast[0].wind.should_not be_nil
      @measurement.forecast[0].wind.to_i.should == 16
      @measurement.forecast[0].wind.degrees.to_i.should == 288
      @measurement.forecast[0].wind.direction.should == "WNW"
      
      # sun_rise = Barometer::Zone.merge("6:02 am", "5/4/09 12:25 AM PDT", -7)
      # sun_set = Barometer::Zone.merge("7:40 pm", "5/4/09 12:25 AM PDT", -7)
      # @measurement.forecast[0].sun.rise.should == sun_rise
      # @measurement.forecast[0].sun.set.should == sun_set
      @measurement.forecast[0].sun.rise.to_s.should == "06:02 am"
      @measurement.forecast[0].sun.set.to_s.should == "07:40 pm"
      
      @measurement.forecast[0].night.should_not be_nil
      @measurement.forecast[0].night.condition.should == "Partly Cloudy"
      @measurement.forecast[0].night.icon.should == "29"
      @measurement.forecast[0].night.pop.to_i.should == 10
      @measurement.forecast[0].night.humidity.to_i.should == 71
      
      @measurement.forecast[0].night.wind.should_not be_nil
      @measurement.forecast[0].night.wind.to_i.should == 14
      @measurement.forecast[0].night.wind.degrees.to_i.should == 335
      @measurement.forecast[0].night.wind.direction.should == "NNW"
    end
    
  end
  
end