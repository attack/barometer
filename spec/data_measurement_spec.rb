require 'spec_helper'

describe "Measurement" do
  
  describe "when initialized" do
    
    before(:each) do
      @measurement = Barometer::Measurement.new
    end
    
    it "responds to source" do
      @measurement.source.should be_nil
    end
    
    it "stores the source" do
      source = :wunderground
      measurement = Barometer::Measurement.new(source)
      measurement.source.should_not be_nil
      measurement.source.should == source
    end
    
    it "responds to time" do
      @measurement.time.should be_nil
    end
    
    it "responds to current" do
      @measurement.current.should be_nil
    end
    
    it "responds to forecast (and defaults to an empty Array)" do
      @measurement.forecast.should be_nil
    end
    
    it "responds to timezone" do
      @measurement.timezone.should be_nil
    end
    
    it "responds to station" do
      @measurement.station.should be_nil
    end
    
    it "responds to location" do
      @measurement.location.should be_nil
    end
    
    it "responds to success" do
      @measurement.success.should be_false
    end
    
    it "responds to current?" do
      @measurement.current?.should be_false
    end
    
    it "responds to metric" do
      @measurement.metric.should be_true
    end
    
  end
  
  describe "when writing data" do
    
    before(:each) do
      @measurement = Barometer::Measurement.new
    end
    
    it "only accepts Symbol for source" do
      invalid_data = 1
      invalid_data.class.should_not == Symbol
      lambda { @measurement.source = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = :valid
      valid_data.class.should == Symbol
      lambda { @measurement.source = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Time for time" do
      invalid_data = 1
      invalid_data.class.should_not == Time
      lambda { @measurement.time = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Time.now.utc
      valid_data.class.should == Time
      lambda { @measurement.time = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::CurrentMeasurement for current" do
      invalid_data = "invalid"
      invalid_data.class.should_not == Barometer::CurrentMeasurement
      lambda { @measurement.current = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::CurrentMeasurement.new
      valid_data.class.should == Barometer::CurrentMeasurement
      lambda { @measurement.current = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Array for forecast" do
      invalid_data = 1
      invalid_data.class.should_not == Array
      lambda { @measurement.forecast = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = []
      valid_data.class.should == Array
      lambda { @measurement.forecast = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Zone for timezone" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Zone
      lambda { @measurement.timezone = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Zone.new("Europe/Paris")
      valid_data.class.should == Barometer::Zone
      lambda { @measurement.timezone = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Location for station" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Location
      lambda { @measurement.station = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Location.new
      valid_data.class.should == Barometer::Location
      lambda { @measurement.station = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Location for location" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Location
      lambda { @measurement.location = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Location.new
      valid_data.class.should == Barometer::Location
      lambda { @measurement.location = valid_data }.should_not raise_error(ArgumentError)
    end
    
  end
  
  describe "and the helpers" do
    
    before(:each) do
      @measurement = Barometer::Measurement.new
    end
    
    it "changes state to successful (if successful)" do
      @measurement.success.should be_false
      @measurement.success!
      @measurement.time.should be_nil
      @measurement.current.should be_nil
      @measurement.success.should be_false
      
      @measurement.current = Barometer::CurrentMeasurement.new
      @measurement.current.temperature = Barometer::Temperature.new
      @measurement.current.temperature.c = 10
      @measurement.time.should_not be_nil
      @measurement.success!
      @measurement.success.should be_true
    end
    
    it "returns successful state" do
      @measurement.current = Barometer::CurrentMeasurement.new
      @measurement.current.temperature = Barometer::Temperature.new
      @measurement.current.temperature.c = 10
      @measurement.success!
      @measurement.success.should be_true
      @measurement.success?.should be_true
    end
    
    it "returns non-successful state" do
      @measurement.success.should be_false
      @measurement.success?.should be_false
    end
    
    it "stamps the time" do
      @measurement.time.should be_nil
      @measurement.stamp!
      @measurement.time.should_not be_nil
    end
    
    it "indicates if current" do
      @measurement.time.should be_nil
      @measurement.current?.should be_false
      @measurement.stamp!
      @measurement.time.should_not be_nil
      @measurement.current?.should be_true
      
      @measurement.time -= (60*60*3)
      @measurement.current?.should be_true
      
      @measurement.time -= (60*60*5)
      @measurement.current?.should be_false
    end
    
    describe "changing units" do

      before(:each) do
        @measurement = Barometer::Measurement.new
      end

      it "indicates if metric?" do
        @measurement.metric.should be_true
        @measurement.metric?.should be_true
        @measurement.metric = false
        @measurement.metric.should be_false
        @measurement.metric?.should be_false
      end

      it "changes to imperial" do
        @measurement.metric?.should be_true
        @measurement.imperial!
        @measurement.metric?.should be_false
      end

      it "changes to metric" do
        @measurement.metric = false
        @measurement.metric?.should be_false
        @measurement.metric!
        @measurement.metric?.should be_true
      end

    end

  end
  
  describe "when searching forecasts using 'for'" do
    
    before(:each) do
      @measurement = Barometer::Measurement.new
      
      # create a measurement object with a forecast array that includes
      # dates for 4 consecutive days starting with tommorrow
      @measurement.forecast = []
      1.upto(4) do |i|
        forecast_measurement = Barometer::ForecastMeasurement.new
        forecast_measurement.date = Date.parse((Time.now + (i * 60 * 60 * 24)).to_s)
        @measurement.forecast << forecast_measurement
      end
      @measurement.forecast.size.should == 4
      
      @tommorrow = (Time.now + (60 * 60 * 24))
    end
    
    it "returns nil when there are no forecasts" do
      @measurement.forecast = []
      @measurement.forecast.size.should == 0
      @measurement.for.should be_nil
    end
    
    it "finds the date using a String" do
      tommorrow = @tommorrow.to_s
      tommorrow.class.should == String
      @measurement.for(tommorrow).should == @measurement.forecast.first
    end
    
    it "finds the date using a Date" do
      tommorrow = Date.parse(@tommorrow.to_s)
      tommorrow.class.should == Date
      @measurement.for(tommorrow).should == @measurement.forecast.first
    end
    
    it "finds the date using a DateTime" do
      tommorrow = DateTime.parse(@tommorrow.to_s)
      tommorrow.class.should == DateTime
      @measurement.for(tommorrow).should == @measurement.forecast.first
    end
    
    it "finds the date using a Time" do
      @tommorrow.class.should == Time
      @measurement.for(@tommorrow).should == @measurement.forecast.first
    end
    
    it "finds nothing when there is not a match" do
      yesterday = (Time.now - (60 * 60 * 24))
      yesterday.class.should == Time
      @measurement.for(yesterday).should be_nil
    end
    
  end
  
  describe "when answering the simple questions," do
    
    before(:each) do
      @measurement = Barometer::Measurement.new(:wunderground)
    end
    
    describe "windy?" do
      
      it "requires threshold as a number" do
        lambda { @measurement.windy?("a") }.should raise_error(ArgumentError)
        lambda { @measurement.windy?(1) }.should_not raise_error(ArgumentError)
        lambda { @measurement.windy?(1.1) }.should_not raise_error(ArgumentError)
      end
      
      it "requires time as a Time object" do
        lambda { @measurement.windy?(1,"a") }.should raise_error(ArgumentError)
        lambda { @measurement.windy?(1,Time.now.utc) }.should_not raise_error(ArgumentError)
      end

      it "returns true if a source returns true" do
        module Barometer; class Service
          def self.windy?(a=nil,b=nil,c=nil); true; end
        end; end
        @measurement.windy?.should be_true
      end

      it "returns false if a measurement returns false" do
        module Barometer; class Service
          def self.windy?(a=nil,b=nil,c=nil); false; end
        end; end
        @measurement.windy?.should be_false
      end
      
    end
    
    describe "wet?" do
      
      it "requires threshold as a number" do
        lambda { @measurement.wet?("a") }.should raise_error(ArgumentError)
        lambda { @measurement.wet?(1) }.should_not raise_error(ArgumentError)
        lambda { @measurement.wet?(1.1) }.should_not raise_error(ArgumentError)
      end
      
      it "requires time as a Time object" do
        lambda { @measurement.wet?(1,"a") }.should raise_error(ArgumentError)
        lambda { @measurement.wet?(1,Time.now.utc) }.should_not raise_error(ArgumentError)
      end

      it "returns true if a source returns true" do
        module Barometer; class Service
          def self.wet?(a=nil,b=nil,c=nil); true; end
        end; end
        @measurement.wet?.should be_true
      end

      it "returns false if a measurement returns false" do
        module Barometer; class Service
          def self.wet?(a=nil,b=nil,c=nil); false; end
        end; end
        @measurement.wet?.should be_false
      end
      
    end
    
  end
  
end
