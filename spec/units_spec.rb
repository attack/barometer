require 'spec_helper'

describe "Units" do
  
  describe "when initialized" do
    
    before(:each) do
      @units = Barometer::Units.new
    end
    
    it "responds to metric, defaults to true" do
      @units.metric.should be_true
    end
    
    it "allows metric to be set" do
      @units.metric.should be_true
      
      @units2 = Barometer::Units.new(false)
      @units2.metric.should be_false
    end
    
  end
  
  describe "changing units" do
    
    before(:each) do
      @units = Barometer::Units.new
    end
    
    it "indicates if metric?" do
      @units.metric.should be_true
      @units.metric?.should be_true
      @units.metric = false
      @units.metric.should be_false
      @units.metric?.should be_false
    end
    
    it "changes to imperial" do
      @units.metric?.should be_true
      @units.imperial!
      @units.metric?.should be_false
    end
    
    it "changes to metric" do
      @units.metric = false
      @units.metric?.should be_false
      @units.metric!
      @units.metric?.should be_true
    end

  end

end