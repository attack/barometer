require 'spec_helper'

describe "Weather" do
  
  describe "when initialized" do
    
    before(:each) do
      @weather = Barometer::Weather.new
    end

    it "responds to measurements (and sets default value)" do
      @weather.measurements.should == []
    end

    it "responds to current" do
      @weather.respond_to?("current").should be_true
    end

    it "responds to forecast" do
      @weather.respond_to?("forecast").should be_true
    end

    it "responds to today" do
      @weather.respond_to?("today").should be_true
    end

    it "responds to tommorrow" do
      @weather.respond_to?("tomorrow").should be_true
    end

    it "responds to for" do
      @weather.respond_to?("for").should be_true
    end

  end
  
  describe "with measurements" do
    
    before(:each) do
      module Barometer
        class Measurement
          attr_accessor :success
        end
      end
      @weather = Barometer::Weather.new
      @wunderground = Barometer::Measurement.new(:wunderground)
      @wunderground.success = true
      @yahoo = Barometer::Measurement.new(:yahoo)
      @yahoo.success = true
      @google = Barometer::Measurement.new(:google)
      @weather.measurements << @wunderground
      @weather.measurements << @yahoo
      @weather.measurements << @google
    end
    
    it "retrieves a source measurement" do
      lambda { @weather.source(1) }.should raise_error(ArgumentError)
      lambda { @weather.source("valid") }.should_not raise_error(ArgumentError)
      lambda { @weather.source(:valid) }.should_not raise_error(ArgumentError)
      @weather.source(:does_not_exist).should be_nil
      @weather.source(:wunderground).should == @wunderground
    end
    
    it "lists the sources of measurements (that were successful)" do
      sources = @weather.sources
      sources.should_not be_nil
      @wunderground.success?.should be_true
      sources.include?(:wunderground).should be_true
      @yahoo.success?.should be_true
      sources.include?(:yahoo).should be_true
      @google.success?.should be_false
      sources.include?(:google).should be_false
    end
    
    it "returns the default source" do
      @weather.default.should == @wunderground
    end
    
  end
  
  describe "when calculating averages" do
    
    before(:each) do
      @weather = Barometer::Weather.new
      @wunderground = Barometer::Measurement.new(:wunderground)
      @wunderground.current = Barometer::CurrentMeasurement.new
      @wunderground.success = true
      @yahoo = Barometer::Measurement.new(:yahoo)
      @yahoo.current = Barometer::CurrentMeasurement.new
      @yahoo.success = true
      @google = Barometer::Measurement.new(:google)
      @weather.measurements << @wunderground
      @weather.measurements << @yahoo
      @weather.measurements << @google
    end
    
    it "doesn't include nil values" do
      @weather.source(:wunderground).current.temperature = Barometer::Temperature.new
      @weather.source(:wunderground).current.temperature.c = 10
      
      @weather.temperature.c.should == 10
      
      @weather.source(:yahoo).current.temperature = Barometer::Temperature.new
      @weather.source(:yahoo).current.temperature.c = nil
      
      @weather.temperature.c.should == 10
    end
    
    describe "for temperature" do
      
      before(:each) do
        @weather.source(:wunderground).current.temperature = Barometer::Temperature.new
        @weather.source(:wunderground).current.temperature.c = 10
        @weather.source(:yahoo).current.temperature = Barometer::Temperature.new
        @weather.source(:yahoo).current.temperature.c = 6
      end

      it "returns averages" do
        @weather.temperature.c.should == 8
      end
      
      it "returns default when disabled" do
        @weather.temperature(false).c.should == 10
      end
      
    end
    
    describe "for wind" do
      
      before(:each) do
        @weather.source(:wunderground).current.wind = Barometer::Speed.new
        @weather.source(:wunderground).current.wind.kph = 10
        @weather.source(:yahoo).current.wind = Barometer::Speed.new
        @weather.source(:yahoo).current.wind.kph = 6
      end

      it "returns averages" do
        @weather.wind.kph.should == 8
      end
      
      it "returns default when disabled" do
        @weather.wind(false).kph.should == 10
      end
      
    end
    
    describe "for humidity" do
      
      before(:each) do
        @weather.source(:wunderground).current.humidity = 10
        @weather.source(:yahoo).current.humidity = 6
      end

      it "returns averages" do
        @weather.humidity.should == 8
      end
      
      it "returns default when disabled" do
        @weather.humidity(false).should == 10
      end
      
    end
    
    describe "for pressure" do
      
      before(:each) do
        @weather.source(:wunderground).current.pressure = Barometer::Pressure.new
        @weather.source(:wunderground).current.pressure.mb = 10
        @weather.source(:yahoo).current.pressure = Barometer::Pressure.new
        @weather.source(:yahoo).current.pressure.mb = 6
      end

      it "returns averages" do
        @weather.pressure.mb.should == 8
      end
      
      it "returns default when disabled" do
        @weather.pressure(false).mb.should == 10
      end
      
    end
    
    describe "for dew_point" do
      
      before(:each) do
        @weather.source(:wunderground).current.dew_point = Barometer::Temperature.new
        @weather.source(:wunderground).current.dew_point.c = 10
        @weather.source(:yahoo).current.dew_point = Barometer::Temperature.new
        @weather.source(:yahoo).current.dew_point.c = 6
      end

      it "returns averages" do
        @weather.dew_point.c.should == 8
      end
      
      it "returns default when disabled" do
        @weather.dew_point(false).c.should == 10
      end
      
    end
    
    describe "for heat_index" do
      
      before(:each) do
        @weather.source(:wunderground).current.heat_index = Barometer::Temperature.new
        @weather.source(:wunderground).current.heat_index.c = 10
        @weather.source(:yahoo).current.heat_index = Barometer::Temperature.new
        @weather.source(:yahoo).current.heat_index.c = 6
      end

      it "returns averages" do
        @weather.heat_index.c.should == 8
      end
      
      it "returns default when disabled" do
        @weather.heat_index(false).c.should == 10
      end
      
    end
    
    describe "for wind_chill" do
      
      before(:each) do
        @weather.source(:wunderground).current.wind_chill = Barometer::Temperature.new
        @weather.source(:wunderground).current.wind_chill.c = 10
        @weather.source(:yahoo).current.wind_chill = Barometer::Temperature.new
        @weather.source(:yahoo).current.wind_chill.c = 6
      end

      it "returns averages" do
        @weather.wind_chill.c.should == 8
      end
      
      it "returns default when disabled" do
        @weather.wind_chill(false).c.should == 10
      end
      
    end
    
    describe "for visibility" do
      
      before(:each) do
        @weather.source(:wunderground).current.visibility = Barometer::Distance.new
        @weather.source(:wunderground).current.visibility.km = 10
        @weather.source(:yahoo).current.visibility = Barometer::Distance.new
        @weather.source(:yahoo).current.visibility.km = 6
      end

      it "returns averages" do
        @weather.visibility.km.should == 8
      end
      
      it "returns default when disabled" do
        @weather.visibility(false).km.should == 10
      end
      
    end
    
  end
  
  describe "when answering the simple questions," do
    
    before(:each) do
      @weather = Barometer::Weather.new
    end
    
    describe "windy?" do
      
      it "requires threshold as a number" do
        lambda { @weather.windy?("a") }.should raise_error(ArgumentError)
        lambda { @weather.windy?(1) }.should_not raise_error(ArgumentError)
        lambda { @weather.windy?(1.1) }.should_not raise_error(ArgumentError)
      end
      
      it "requires time as a Time object" do
        lambda { @weather.windy?(1,"a") }.should raise_error(ArgumentError)
        lambda { @weather.windy?(1,Time.now.utc) }.should_not raise_error(ArgumentError)
      end
      
      it "returns nil when no measurements" do
        @weather.measurements.should be_empty
        @weather.windy?.should be_nil
      end
      
      it "returns true if a measurement returns true" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.success = true
        @weather.measurements << wunderground
        module Barometer; class Measurement
            def windy?(a=nil,b=nil); true; end
        end; end
        @weather.windy?.should be_true
      end

      it "returns false if a measurement returns false" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.success = true
        @weather.measurements << wunderground
        module Barometer; class Measurement
            def windy?(a=nil,b=nil); false; end
        end; end
        @weather.windy?.should be_false
      end
      
    end
    
    describe "wet?" do
      
      it "requires threshold as a number" do
        lambda { @weather.wet?("a") }.should raise_error(ArgumentError)
        lambda { @weather.wet?(1) }.should_not raise_error(ArgumentError)
        lambda { @weather.wet?(1.1) }.should_not raise_error(ArgumentError)
      end
      
      it "requires time as a Time object" do
        lambda { @weather.wet?(1,"a") }.should raise_error(ArgumentError)
        lambda { @weather.wet?(1,Time.now.utc) }.should_not raise_error(ArgumentError)
      end
      
      it "returns nil when no measurements" do
        @weather.measurements.should be_empty
        @weather.wet?.should be_nil
      end
      
      it "returns true if a measurement returns true" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.success = true
        @weather.measurements << wunderground
        module Barometer; class Measurement
            def wet?(a=nil,b=nil); true; end
        end; end
        @weather.wet?.should be_true
      end

      it "returns false if a measurement returns false" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.success = true
        @weather.measurements << wunderground
        module Barometer; class Measurement
            def wet?(a=nil,b=nil); false; end
        end; end
        @weather.wet?.should be_false
      end
      
    end
    
    describe "day? and night?" do
      
      it "requires time as a Time object" do
        lambda { @weather.day?("a") }.should raise_error(ArgumentError)
        lambda { @weather.day?(Time.now.utc) }.should_not raise_error(ArgumentError)
      end
      
      it "requires time as a Time object" do
        lambda { @weather.night?("a") }.should raise_error(ArgumentError)
        lambda { @weather.night?(Time.now.utc) }.should_not raise_error(ArgumentError)
      end
      
      it "returns nil when no measurements" do
        @weather.measurements.should be_empty
        @weather.day?.should be_nil
        @weather.night?.should be_nil
      end
      
      it "returns true if a measurement returns true (night is opposite)" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.success = true
        @weather.measurements << wunderground
        module Barometer; class Measurement
            def day?(a=nil); true; end
        end; end
        @weather.day?.should be_true
        @weather.night?.should be_false
      end

      it "returns false if a measurement returns false (night is opposite)" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.success = true
        @weather.measurements << wunderground
        module Barometer; class Measurement
            def day?(a=nil); false; end
        end; end
        @weather.day?.should be_false
        @weather.night?.should be_true
      end
      
    end
    
    describe "sunny?" do
      
      it "requires time as a Time object" do
        lambda { @weather.sunny?("a") }.should raise_error(ArgumentError)
        lambda { @weather.sunny?(Time.now.utc) }.should_not raise_error(ArgumentError)
      end
      
      it "returns nil when no measurements" do
        @weather.measurements.should be_empty
        @weather.sunny?.should be_nil
      end
      
      it "returns true if a measurement returns true" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.success = true
        @weather.measurements << wunderground
        module Barometer; class Measurement
            def day?(a=nil); true; end
        end; end
        module Barometer; class Measurement
            def sunny?(a=nil,b=nil); true; end
        end; end
        @weather.sunny?.should be_true
      end

      it "returns false if a measurement returns false" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.success = true
        @weather.measurements << wunderground
        module Barometer; class Measurement
            def day?(a=nil); true; end
        end; end
        module Barometer; class Measurement
            def sunny?(a=nil,b=nil); false; end
        end; end
        @weather.sunny?.should be_false
      end
      
      it "returns false if night time" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.success = true
        @weather.measurements << wunderground
        module Barometer; class Measurement
            def sunny?(a=nil,b=nil); true; end
        end; end
        @weather.sunny?.should be_true
        module Barometer; class Measurement
            def day?(a=nil); false; end
        end; end
        @weather.sunny?.should be_false
      end

    end
    
  end
  
end