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
    
    it "responds to current" do
      @measurement.current.should be_nil
    end
    
    it "responds to forecast (and defaults to an empty Array)" do
      @measurement.forecast.should == []
    end
    
    it "responds to timezone" do
      @measurement.timezone.should be_nil
    end
    
    it "responds to station" do
      @measurement.station.should be_nil
    end
    
    it "responds to success" do
      @measurement.success.should be_false
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
    
    it "only accepts String for timezone" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @measurement.timezone = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = "valid"
      valid_data.class.should == String
      lambda { @measurement.timezone = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Temperature for station" do
      invalid_data = 1
      invalid_data.class.should_not == Hash
      lambda { @measurement.station = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = {}
      valid_data.class.should == Hash
      lambda { @measurement.station = valid_data }.should_not raise_error(ArgumentError)
    end
    
  end
  
  describe "and the helpers" do
    
    before(:each) do
      @measurement = Barometer::Measurement.new
    end
    
    it "changes state to successful" do
      @measurement.success.should be_false
      @measurement.success!
      @measurement.success.should be_true
    end
    
    it "returns successful state" do
      @measurement.success!
      @measurement.success.should be_true
      @measurement.success?.should be_true
    end
    
    it "returns non-successful state" do
      @measurement.success.should be_false
      @measurement.success?.should be_false
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
  
end
