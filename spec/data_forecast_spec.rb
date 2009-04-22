require 'spec_helper'

describe "Forecast Measurement" do
  
  describe "when initialized" do
    
    before(:each) do
      @forecast = Barometer::ForecastMeasurement.new
    end
    
    it "responds to date" do
      @forecast.date.should be_nil
    end
    
    it "responds to icon" do
      @forecast.icon.should be_nil
    end
    
    it "responds to low" do
      @forecast.low.should be_nil
    end
    
    it "responds to high" do
      @forecast.high.should be_nil
    end
    
  end
  
  describe "when writing data" do
    
    before(:each) do
      @forecast = Barometer::ForecastMeasurement.new
    end
    
    # it "only accepts Date for date" do
    #   invalid_data = 1
    #   invalid_data.class.should_not == Time::Date
    #   lambda { @forecast.date = invalid_data }.should raise_error(ArgumentError)
    #   
    #   valid_data = Time::Date.new
    #   valid_data.class.should == Time::Date
    #   lambda { @forecast.date = valid_data }.should_not raise_error(ArgumentError)
    # end
    
    it "only accepts String for icon" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @forecast.icon = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = "valid"
      valid_data.class.should == String
      lambda { @forecast.icon = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Temperature for high" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Temperature
      lambda { @forecast.high = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Temperature.new
      valid_data.class.should == Barometer::Temperature
      lambda { @forecast.high = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Temperature for low" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Temperature
      lambda { @forecast.low = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Temperature.new
      valid_data.class.should == Barometer::Temperature
      lambda { @forecast.low = valid_data }.should_not raise_error(ArgumentError)
    end
    
  end
  
end