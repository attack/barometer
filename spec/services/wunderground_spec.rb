require 'spec_helper'

describe "Wunderground" do
  
  before(:each) do
    @accepted_formats = [:zipcode, :postalcode, :icao, :coordinates, :geocode]
    @base_uri = "http://api.wunderground.com/auto/wui/geo"
  end
  
  describe "the class methods" do
    
    it "defines accepted_formats" do
      Barometer::Wunderground.accepted_formats.should == @accepted_formats
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
      current.is_a?(Data::CurrentMeasurement).should be_true
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
    
    it "returns Barometer::Location object" do
      station = Barometer::Wunderground.build_station({})
      station.is_a?(Data::Location).should be_true
    end
    
  end
  
  describe "building the location data" do
    
    it "defines the build method" do
      Barometer::Wunderground.respond_to?("build_location").should be_true
    end
    
    it "requires Hash input" do
      lambda { Barometer::Wunderground.build_location }.should raise_error(ArgumentError)
      lambda { Barometer::Wunderground.build_location({}) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Location object" do
      location = Barometer::Wunderground.build_location({})
      location.is_a?(Data::Location).should be_true
    end
    
  end
  
  describe "building the timezone" do
    
    it "defines the build method" do
      Barometer::Wunderground.respond_to?("build_timezone").should be_true
    end
    
    it "requires Hash input" do
      lambda { Barometer::Wunderground.build_timezone }.should raise_error(ArgumentError)
      lambda { Barometer::Wunderground.build_timezone({}) }.should_not raise_error(ArgumentError)
    end
    
  end
  
  describe "building the sun data" do
       
    before(:each) do
      @zone = Data::Zone.new("Europe/Paris")
    end

    it "defines the build method" do
      Barometer::Wunderground.respond_to?("build_sun").should be_true
    end
    
    it "requires Hash input" do
      lambda { Barometer::Wunderground.build_sun }.should raise_error(ArgumentError)
      lambda { Barometer::Wunderground.build_sun({},@zone) }.should_not raise_error(ArgumentError)
    end
    
    it "requires Barometer::Zone input" do
      lambda { Barometer::Wunderground.build_sun({}) }.should raise_error(ArgumentError)
      lambda { Barometer::Wunderground.build_sun({}, "invalid") }.should raise_error(ArgumentError)
      lambda { Barometer::Wunderground.build_sun({},@zone) }.should_not raise_error(ArgumentError)
    end
    
    it "returns Barometer::Sun object" do
      sun = Barometer::Wunderground.build_sun({},@zone)
      sun.is_a?(Data::Sun).should be_true
    end
    
  end
  
  describe "when measuring" do

    before(:each) do
      @query = Barometer::Query.new("Calgary,AB")
      @query.preferred = "Calgary,AB"
      @measurement = Data::Measurement.new
      
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape(@query.preferred)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          '../fixtures/services/wunderground',
          'current_calgary_ab.xml')
        )
      )  
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape(@query.preferred)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          '../fixtures/services/wunderground',
          'forecast_calgary_ab.xml')
        )
      )
    end
    
    describe "all" do
      
      it "responds to _measure" do
        Barometer::Wunderground.respond_to?("_measure").should be_true
      end
      
      it "requires a Barometer::Measurement object" do
        lambda { Barometer::Wunderground._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { Barometer::Wunderground._measure("invlaid", @query) }.should raise_error(ArgumentError)

        lambda { Barometer::Wunderground._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "requires a Barometer::Query query" do
        lambda { Barometer::Wunderground._measure }.should raise_error(ArgumentError)
        lambda { Barometer::Wunderground._measure(@measurement, 1) }.should raise_error(ArgumentError)
        
        lambda { Barometer::Wunderground._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end
      
      it "returns a Barometer::Measurement object" do
        result = Barometer::Wunderground._measure(@measurement, @query)
        result.is_a?(Data::Measurement).should be_true
        result.current.is_a?(Data::CurrentMeasurement).should be_true
        result.forecast.is_a?(Array).should be_true
        
        result.source.should == :wunderground
      end
      
    end

  end
  
  describe "when answering the simple questions," do
    
    before(:each) do
      @measurement = Data::Measurement.new
    end
    
    describe "currently_wet_by_icon?" do
      
      before(:each) do
        @measurement.current = Data::CurrentMeasurement.new
      end

      it "returns true if matching icon code" do
        @measurement.current.icon = "rain"
        @measurement.current.icon?.should be_true
        Barometer::Wunderground.currently_wet_by_icon?(@measurement.current).should be_true
      end
      
      it "returns false if NO matching icon code" do
        @measurement.current.icon = "sunny"
        @measurement.current.icon?.should be_true
        Barometer::Wunderground.currently_wet_by_icon?(@measurement.current).should be_false
      end
      
    end
    
    describe "forecasted_wet_by_icon?" do
      
      before(:each) do
        @measurement.forecast = [Data::ForecastMeasurement.new]
        @measurement.forecast.first.date = Date.today
        @measurement.forecast.size.should == 1
      end

      it "returns true if matching icon code" do
        @measurement.forecast.first.icon = "rain"
        @measurement.forecast.first.icon?.should be_true
        Barometer::Wunderground.forecasted_wet_by_icon?(@measurement.forecast.first).should be_true
      end
      
      it "returns false if NO matching icon code" do
        @measurement.forecast.first.icon = "sunny"
        @measurement.forecast.first.icon?.should be_true
        Barometer::Wunderground.forecasted_wet_by_icon?(@measurement.forecast.first).should be_false
      end
      
    end
    
    describe "currently_sunny_by_icon?" do
      
      before(:each) do
        @measurement.current = Data::CurrentMeasurement.new
      end

      it "returns true if matching icon code" do
        @measurement.current.icon = "sunny"
        @measurement.current.icon?.should be_true
        Barometer::Wunderground.currently_sunny_by_icon?(@measurement.current).should be_true
      end
      
      it "returns false if NO matching icon code" do
        @measurement.current.icon = "rain"
        @measurement.current.icon?.should be_true
        Barometer::Wunderground.currently_sunny_by_icon?(@measurement.current).should be_false
      end
      
    end
    
    describe "forecasted_sunny_by_icon?" do
      
      before(:each) do
        @measurement.forecast = [Data::ForecastMeasurement.new]
        @measurement.forecast.first.date = Date.today
        @measurement.forecast.size.should == 1
      end

      it "returns true if matching icon code" do
        @measurement.forecast.first.icon = "sunny"
        @measurement.forecast.first.icon?.should be_true
        Barometer::Wunderground.forecasted_sunny_by_icon?(@measurement.forecast.first).should be_true
      end
      
      it "returns false if NO matching icon code" do
        @measurement.forecast.first.icon = "rain"
        @measurement.forecast.first.icon?.should be_true
        Barometer::Wunderground.forecasted_sunny_by_icon?(@measurement.forecast.first).should be_false
      end
      
    end
    
  end
  
  describe "overall data correctness" do
    
    before(:each) do
      @query = Barometer::Query.new("Calgary,AB")
      @query.preferred = "Calgary,AB"
      @measurement = Data::Measurement.new
      
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape(@query.preferred)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          '../fixtures/services/wunderground',
          'current_calgary_ab.xml')
        )
      )  
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape(@query.preferred)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          '../fixtures/services/wunderground',
          'forecast_calgary_ab.xml')
        )
      )
    end

   # TODO: complete this
   it "should correctly build the data" do
      result = Barometer::Wunderground._measure(@measurement, @query)
      
      # build timezone
      @measurement.timezone.timezone.should == "America/Edmonton"
      
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