require 'spec_helper'

describe "Current Measurement" do
  
  describe "when initialized" do
    
    before(:each) do
      @current = Barometer::CurrentMeasurement.new
    end
    
    it "responds to time" do
      @current.time.should be_nil
    end
    
    it "responds to humidity" do
      @current.humidity.should be_nil
    end
    
    it "responds to icon" do
      @current.icon.should be_nil
    end
    
    it "responds to condition" do
      @current.condition.should be_nil
    end
    
    it "responds to temperature" do
      @current.temperature.should be_nil
    end
    
    it "responds to dew_point" do
      @current.dew_point.should be_nil
    end
    
    it "responds to heat_index" do
      @current.heat_index.should be_nil
    end
    
    it "responds to wind_chill" do
      @current.wind_chill.should be_nil
    end
    
    it "responds to wind" do
      @current.wind.should be_nil
    end
    
    it "responds to pressure" do
      @current.pressure.should be_nil
    end
    
    it "responds to visibility" do
      @current.pressure.should be_nil
    end
    
  end
  
  describe "when writing data" do
    
    before(:each) do
      @current = Barometer::CurrentMeasurement.new
    end
    
    # it "only accepts Time for time" do
    #   invalid_data = 1
    #   invalid_data.class.should_not == Time
    #   lambda { @current.time = invalid_data }.should raise_error(ArgumentError)
    #   
    #   valid_data = Time.new
    #   valid_data.class.should == Time
    #   lambda { @current.time = valid_data }.should_not raise_error(ArgumentError)
    # end
    
    it "only accepts Fixnum or Float for humidity" do
      invalid_data = "invalid"
      invalid_data.class.should_not == Fixnum
      invalid_data.class.should_not == Float
      lambda { @current.humidity = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = 1.to_i
      valid_data.class.should == Fixnum
      lambda { @current.humidity = valid_data }.should_not raise_error(ArgumentError)
      
      valid_data = 1.0.to_f
      valid_data.class.should == Float
      lambda { @current.humidity = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts String for icon" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @current.icon = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = "valid"
      valid_data.class.should == String
      lambda { @current.icon = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts String for condition" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @current.condition = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = "valid"
      valid_data.class.should == String
      lambda { @current.condition = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Temperature for temperature" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Temperature
      lambda { @current.temperature = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Temperature.new
      valid_data.class.should == Barometer::Temperature
      lambda { @current.temperature = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Temperature for dew_point" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Temperature
      lambda { @current.dew_point = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Temperature.new
      valid_data.class.should == Barometer::Temperature
      lambda { @current.dew_point = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Temperature for heat_index" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Temperature
      lambda { @current.heat_index = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Temperature.new
      valid_data.class.should == Barometer::Temperature
      lambda { @current.heat_index = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Temperature for wind_chill" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Temperature
      lambda { @current.wind_chill = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Temperature.new
      valid_data.class.should == Barometer::Temperature
      lambda { @current.wind_chill = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Speed for wind" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Speed
      lambda { @current.wind = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Speed.new
      valid_data.class.should == Barometer::Speed
      lambda { @current.wind = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Pressure for pressure" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Pressure
      lambda { @current.pressure = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Pressure.new
      valid_data.class.should == Barometer::Pressure
      lambda { @current.pressure = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Barometer::Distance for visibility" do
      invalid_data = 1
      invalid_data.class.should_not == Barometer::Distance
      lambda { @current.visibility = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Barometer::Distance.new
      valid_data.class.should == Barometer::Distance
      lambda { @current.visibility = valid_data }.should_not raise_error(ArgumentError)
    end
    
  end
  
  describe "method missing" do
    
    before(:each) do
      @current = Barometer::CurrentMeasurement.new
    end
    
    it "responds to method + ?" do
      valid_method = "humidity"
      @current.respond_to?(valid_method).should be_true
      lambda { @current.send(valid_method + "?") }.should_not raise_error(NoMethodError)
    end
    
    it "ignores non_method + ?" do
      invalid_method = "humid"
      @current.respond_to?(invalid_method).should be_false
      lambda { @current.send(invalid_method + "?") }.should raise_error(NoMethodError)
    end
    
    it "returns true if set" do
      @current.humidity = 10
      @current.humidity.should_not be_nil
      @current.humidity?.should be_true
    end
    
    it "returns false if not set" do
      @current.humidity.should be_nil
      @current.humidity?.should be_false
    end
    
  end
  
end