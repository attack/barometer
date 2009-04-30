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
    
    it "requires Barometer::Geo input" do
      geo = Barometer::Geo.new({})
      lambda { Barometer::Yahoo.build_location({}, {}) }.should raise_error(ArgumentError)
      lambda { Barometer::Yahoo.build_location({}, geo) }.should_not raise_error(ArgumentError)
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
      @query = Barometer::Query.new("90210")
      @query.preferred = "90210"
      @measurement = Barometer::Measurement.new
      
      FakeWeb.register_uri(:get, 
        "http://weather.yahooapis.com:80/forecastrss?u=c&p=#{CGI.escape(@query.preferred)}",
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
  
      it "requires a Barometer::Query query" do
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
  
  describe "when answering the simple questions," do
    
    before(:each) do
      @measurement = Barometer::Measurement.new
    end
    
    describe "currently_wet_by_icon?" do
      
      before(:each) do
        @measurement.current = Barometer::CurrentMeasurement.new
      end

      it "returns true if matching icon code" do
        @measurement.current.icon = "4"
        @measurement.current.icon?.should be_true
        Barometer::Yahoo.currently_wet_by_icon?(@measurement.current).should be_true
      end
      
      it "returns false if NO matching icon code" do
        @measurement.current.icon = "32"
        @measurement.current.icon?.should be_true
        Barometer::Yahoo.currently_wet_by_icon?(@measurement.current).should be_false
      end
      
    end
    
    describe "forecasted_wet_by_icon?" do
      
      before(:each) do
        @measurement.forecast = [Barometer::ForecastMeasurement.new]
        @measurement.forecast.first.date = Date.today
        @measurement.forecast.size.should == 1
      end

      it "returns true if matching icon code" do
        @measurement.forecast.first.icon = "4"
        @measurement.forecast.first.icon?.should be_true
        Barometer::Yahoo.forecasted_wet_by_icon?(@measurement.forecast.first).should be_true
      end
      
      it "returns false if NO matching icon code" do
        @measurement.forecast.first.icon = "32"
        @measurement.forecast.first.icon?.should be_true
        Barometer::Yahoo.forecasted_wet_by_icon?(@measurement.forecast.first).should be_false
      end
      
    end
    
    describe "currently_sunny_by_icon?" do
      
      before(:each) do
        @measurement.current = Barometer::CurrentMeasurement.new
      end

      it "returns true if matching icon code" do
        @measurement.current.icon = "32"
        @measurement.current.icon?.should be_true
        Barometer::Yahoo.currently_sunny_by_icon?(@measurement.current).should be_true
      end
      
      it "returns false if NO matching icon code" do
        @measurement.current.icon = "4"
        @measurement.current.icon?.should be_true
        Barometer::Yahoo.currently_sunny_by_icon?(@measurement.current).should be_false
      end
      
    end
    
    describe "forecasted_sunny_by_icon?" do
      
      before(:each) do
        @measurement.forecast = [Barometer::ForecastMeasurement.new]
        @measurement.forecast.first.date = Date.today
        @measurement.forecast.size.should == 1
      end

      it "returns true if matching icon code" do
        @measurement.forecast.first.icon = "32"
        @measurement.forecast.first.icon?.should be_true
        Barometer::Yahoo.forecasted_sunny_by_icon?(@measurement.forecast.first).should be_true
      end
      
      it "returns false if NO matching icon code" do
        @measurement.forecast.first.icon = "4"
        @measurement.forecast.first.icon?.should be_true
        Barometer::Yahoo.forecasted_sunny_by_icon?(@measurement.forecast.first).should be_false
      end
      
    end
    
  end
  
  describe "overall data correctness" do
    
    before(:each) do
      @query = Barometer::Query.new("90210")
      @query.preferred = "90210"
      @measurement = Barometer::Measurement.new

      FakeWeb.register_uri(:get, 
        "http://weather.yahooapis.com:80/forecastrss?u=c&p=#{CGI.escape(@query.preferred)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'yahoo_90210.xml')
        )
      )  
    end

    # TODO: complete this
    it "should correctly build the data" do
      result = Barometer::Yahoo._measure(@measurement, @query)
      
      sun_rise = Barometer::Zone.merge("6:09 am", "Sun, 26 Apr 2009 10:51 am PDT", "PDT")
      sun_set = Barometer::Zone.merge("7:34 pm", "Sun, 26 Apr 2009 10:51 am PDT", "PDT")
      
      # build current
      @measurement.current.sun.rise.should == sun_rise
      @measurement.current.sun.set.should == sun_set
      
      # builds location
      @measurement.location.city.should == "Beverly Hills"
      
      # builds forecasts
      @measurement.forecast.size.should == 2
      
      @measurement.forecast[0].condition.should == "Mostly Sunny"
      @measurement.forecast[0].icon.should == "34"
      @measurement.forecast[0].sun.rise.should == sun_rise + (60*60*24*0)
      @measurement.forecast[0].sun.set.should == sun_set + (60*60*24*0)
      
      @measurement.forecast[1].condition.should == "Cloudy"
      @measurement.forecast[1].icon.should == "26"
      @measurement.forecast[1].sun.rise.should == sun_rise + (60*60*24*1)
      @measurement.forecast[1].sun.set.should == sun_set + (60*60*24*1)
      
    end
    # <yweather:location city="Beverly Hills" region="CA" country="US"/>
    # <yweather:units temperature="C" distance="km" pressure="mb" speed="kph"/>
    # <yweather:wind chill="17" direction="0" speed="4.83" />
    # <yweather:atmosphere humidity="50" visibility="16.09" pressure="1017" rising="0" />
    # <item>
    #   <geo:lat>34.08</geo:lat>
    #   <geo:long>-118.4</geo:long>
    #   <pubDate>Sun, 26 Apr 2009 10:51 am PDT</pubDate>
    #   <yweather:condition text="Partly Cloudy" code="30" temp="17" date="Sun, 26 Apr 2009 10:51 am PDT" />
    #   <yweather:forecast day="Sun" date="26 Apr 2009" low="11" high="19" 
    #   <yweather:forecast day="Mon" date="27 Apr 2009" low="11" high="18"
    # </item>
    
  end
  
end