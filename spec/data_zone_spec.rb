require 'spec_helper'

describe "Zone" do
  
  describe "and class methods" do
    
    it "responds to load_tzinfo, it loads TZInfo" do
      Barometer::Zone.respond_to?("load_tzinfo").should be_true
      Barometer::Zone.load_tzinfo.should be_true
      lambda { TZInfo }.should_not raise_error
      Barometer::Zone.tzinfo?.should be_true
    end
  
    it "responds to now and returns Time object" do
      Barometer::Zone.respond_to?("now").should be_true
      Barometer::Zone.now.is_a?(Time).should be_true
    end

    it "responds to today and returns Date object" do
      Barometer::Zone.respond_to?("today").should be_true
      Barometer::Zone.today.is_a?(Date).should be_true
    end
    
  end
  
  describe "when initialized" do
    
    before(:each) do
      @zone = Barometer::Zone.new
      @utc = Time.now.utc
      @timezone = "Europe/Paris"
    end
    
    it "responds to time_as_utc" do
      @zone.time_as_utc.should be_nil
    end
    
    it "responds to timezone" do
      @zone.timezone.should be_nil
      
      zone = Barometer::Zone.new(@utc, @timezone)
      zone.timezone.should == @timezone
    end
    
    it "responds to tz" do
      @zone.tz.should be_nil
      zone = Barometer::Zone.new(@utc)
      zone.tz.should be_nil
      
      zone = Barometer::Zone.new(@utc, @timezone)
      zone.tz.should_not be_nil
    end
    
    it "responds to code" do
      @zone.respond_to?("code").should be_true
      zone = Barometer::Zone.new(@utc)
      zone.tz.should be_nil
      zone.code.should == ""
      
      zone = Barometer::Zone.new(@utc, @timezone)
      zone.code.should == "CEST"
    end
    
    it "responds to dst?" do
      @zone.respond_to?("dst?").should be_true
      zone = Barometer::Zone.new(@utc)
      zone.tz.should be_nil
      zone.dst?.should be_nil
    end
    
    it "responds to utc" do
      @zone.respond_to?("utc").should be_true
      zone = Barometer::Zone.new(@utc)
      zone.tz.should be_nil
      zone.utc.should == @utc
      
      zone = Barometer::Zone.new(@utc, @timezone)
      zone.utc.should == @utc
    end
    
    it "responds to local" do
      @zone.respond_to?("local").should be_true
      zone = Barometer::Zone.new(@utc)
      zone.tz.should be_nil
      zone.local.should == @utc
    end
    
    it "responds to now" do
      @zone.respond_to?("now").should be_true
      @zone.now.is_a?(Time).should be_true
    end

    it "responds to today" do
      @zone.respond_to?("today").should be_true
      @zone.today.is_a?(Date).should be_true
    end
    
    it "responds to today" do
      Barometer::Zone.respond_to?("today").should be_true
    end
    
    it "responds to tzinfo?" do
      Barometer::Zone.respond_to?("tzinfo?").should be_true
    end
    
  end
  
end