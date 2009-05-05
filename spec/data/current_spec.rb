require 'spec_helper'

describe "Current Measurement" do
  
  describe "when initialized" do
    
    before(:each) do
      @current = Data::CurrentMeasurement.new
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
    
    it "responds to sun" do
      @current.sun.should be_nil
    end
    
  end
  
  describe "when writing data" do
    
    before(:each) do
      @current = Data::CurrentMeasurement.new
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
    
    it "only accepts Data::Temperature for temperature" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @current.temperature = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @current.temperature = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Temperature for dew_point" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @current.dew_point = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @current.dew_point = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Temperature for heat_index" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @current.heat_index = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @current.heat_index = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Temperature for wind_chill" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @current.wind_chill = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @current.wind_chill = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Speed for wind" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Speed
      lambda { @current.wind = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Speed.new
      valid_data.class.should == Data::Speed
      lambda { @current.wind = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Pressure for pressure" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Pressure
      lambda { @current.pressure = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Pressure.new
      valid_data.class.should == Data::Pressure
      lambda { @current.pressure = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Distance for visibility" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Distance
      lambda { @current.visibility = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Distance.new
      valid_data.class.should == Data::Distance
      lambda { @current.visibility = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Sun for sun" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Sun
      lambda { @current.sun = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Sun.new
      valid_data.class.should == Data::Sun
      lambda { @current.sun = valid_data }.should_not raise_error(ArgumentError)
    end
    
  end
  
  describe "method missing" do
    
    before(:each) do
      @current = Data::CurrentMeasurement.new
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