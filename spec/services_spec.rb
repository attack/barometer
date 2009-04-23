require 'spec_helper'

describe "Services" do
  
  describe "when initialized" do
    
    before(:each) do
      @service = Barometer::Service.new
    end
    
    it "stubs measure_current" do
      lambda { Barometer::Service.measure_current }.should raise_error(NotImplementedError)
    end
    
    it "stubs measure_future" do
      lambda { Barometer::Service.measure_future }.should raise_error(NotImplementedError)
    end
    
    it "stubs measure_all" do
      lambda { Barometer::Service.measure_all }.should raise_error(NotImplementedError)
    end
    
    it "stubs get_current" do
      lambda { Barometer::Service.get_current }.should raise_error(NotImplementedError)
    end
    
    it "stubs get_forecast" do
      lambda { Barometer::Service.get_forecast }.should raise_error(NotImplementedError)
    end
    
    it "stubs accepted_formats" do
      lambda { Barometer::Service.accepted_formats }.should raise_error(NotImplementedError)
    end
    
    it "defaults meets_requirements?" do
      Barometer::Service.meets_requirements?.should be_true
    end
    
    it "defaults supports_country?" do
      Barometer::Service.supports_country?.should be_true
    end
    
    it "defaults requires_keys?" do
      Barometer::Service.requires_keys?.should be_false
    end
    
    it "defaults has_keys?" do
      lambda { Barometer::Service.has_keys? }.should raise_error(NotImplementedError)
    end
    
  end
  
  describe "when measuring" do
    
    before(:each) do
      @query = Barometer::Query.new
    end
    
    it "responds to measure" do
      lambda { Barometer::Service.measure(@query) }.should_not raise_error
    end
    
    it "checks if API keys are required and present"
    
    it "checks if country supported"
    
    it "checks class of location" do
      #Barometer::Service.measure("invalid").should be_nil
      lambda { Barometer::Service.measure("invalid") }.should raise_error(ArgumentError)
    end
    
    it "calls accepted formats"
    
    it "converts query"
    
    it "measures current only when current"
    
    it "measures all whe ntime is all"
    
    it "measures all when later today"
    
    it "measures future only when tomorrow or later"
    
    it "measures all when no time given"
    
  end
  
end