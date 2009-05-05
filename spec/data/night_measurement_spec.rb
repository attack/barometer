require 'spec_helper'

describe "Forecasted Night Measurement" do
  
  describe "when initialized" do
    
    before(:each) do
      @night = Data::NightMeasurement.new
    end
    
    it "responds to date" do
      @night.date.should be_nil
    end
    
    it "responds to icon" do
      @night.icon.should be_nil
    end
    
    it "responds to condition" do
      @night.condition.should be_nil
    end
    
    it "responds to pop" do
      @night.pop.should be_nil
    end
    
    it "responds to humidity" do
      @night.humidity.should be_nil
    end
    
    it "responds to wind" do
      @night.wind.should be_nil
    end
    
  end
  
  describe "when writing data" do
    
    before(:each) do
      @night = Data::NightMeasurement.new
    end
    
    it "only accepts Date for date" do
      invalid_data = 1
      invalid_data.class.should_not == Date
      lambda { @night.date = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Date.new
      valid_data.class.should == Date
      lambda { @night.date = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts String for icon" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @night.icon = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = "valid"
      valid_data.class.should == String
      lambda { @night.icon = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts String for condition" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @night.condition = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = "valid"
      valid_data.class.should == String
      lambda { @night.condition = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Fixnum for pop" do
      invalid_data = "test"
      invalid_data.class.should_not == Fixnum
      lambda { @night.pop = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = 50
      valid_data.class.should == Fixnum
      lambda { @night.pop = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Speed for wind" do
      invalid_data = "test"
      invalid_data.class.should_not == Data::Speed
      lambda { @night.wind = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Speed.new
      valid_data.class.should == Data::Speed
      lambda { @night.wind = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Fixnum for humidity" do
      invalid_data = "test"
      invalid_data.class.should_not == Fixnum
      lambda { @night.humidity = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = 50
      valid_data.class.should == Fixnum
      lambda { @night.humidity = valid_data }.should_not raise_error(ArgumentError)
    end
    
  end
  
  describe "method missing" do
    
    before(:each) do
      @night = Data::NightMeasurement.new
    end
    
    it "responds to method + ?" do
      valid_method = "pop"
      @night.respond_to?(valid_method).should be_true
      lambda { @night.send(valid_method + "?") }.should_not raise_error(NoMethodError)
    end
    
    it "ignores non_method + ?" do
      invalid_method = "humid"
      @night.respond_to?(invalid_method).should be_false
      lambda { @night.send(invalid_method + "?") }.should raise_error(NoMethodError)
    end
    
    it "returns true if set" do
      @night.pop = 10
      @night.pop.should_not be_nil
      @night.pop?.should be_true
    end
    
    it "returns false if not set" do
      @night.pop.should be_nil
      @night.pop?.should be_false
    end
    
  end
  
end