require 'spec_helper'

describe "Forecasted Night Measurement" do
  
  describe "when initialized" do
    
    before(:each) do
      @night = Measurement::ForecastNight.new
    end
    
    it "responds to date" do
      @night.date.should be_nil
    end
    
    it "responds to pop" do
      @night.pop.should be_nil
    end

  end
  
  describe "when writing data" do
    
    before(:each) do
      @night = Measurement::ForecastNight.new
    end
    
    it "only accepts Date for date" do
      invalid_data = 1
      invalid_data.class.should_not == Date
      lambda { @night.date = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Date.new
      valid_data.class.should == Date
      lambda { @night.date = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Fixnum for pop" do
      invalid_data = "test"
      invalid_data.class.should_not == Fixnum
      lambda { @night.pop = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = 50
      valid_data.class.should == Fixnum
      lambda { @night.pop = valid_data }.should_not raise_error(ArgumentError)
    end
    
  end
  
end