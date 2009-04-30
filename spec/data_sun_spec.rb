require 'spec_helper'

describe "Sun" do
  
  describe "when initialized" do
    
    before(:each) do
      @sun = Barometer::Sun.new
      @time_rise = Time.now
      @time_set = Time.now + (60*60*8)
    end
    
    it "responds to rise" do
      @sun.respond_to?("rise").should be_true
    end
    
    it "responds to set" do
      @sun.respond_to?("set").should be_true
    end
    
    it "sets sunrise" do
      sun = Barometer::Sun.new(@time_rise,@time_set)
      sun.rise.should == @time_rise
    end
    
    it "sets sunset" do
      sun = Barometer::Sun.new(@time_rise,@time_set)
      sun.set.should == @time_set
    end
    
    it "requires Time for sunrise" do
      lambda { Barometer::Sun.new("",@time_set) }.should raise_error(ArgumentError)
      lambda { Barometer::Sun.new(@time_rise,@time_set) }.should_not raise_error(ArgumentError)
    end
    
    it "requires Time for sunset" do
      lambda { Barometer::Sun.new(@time_rise,"") }.should raise_error(ArgumentError)
      lambda { Barometer::Sun.new(@time_rise,@time_set) }.should_not raise_error(ArgumentError)
    end
    
    it "responds to nil?" do
      @sun.nil?.should be_true
      sun = Barometer::Sun.new(@time_rise, @time_set)
      sun.nil?.should be_false
    end
    
  end
  
  describe "when adjusting times" do
    
    before(:each) do
      @time_rise = Time.now
      @time_set = Time.now + (60*60*8)
      @sun = Barometer::Sun.new(@time_rise, @time_set)
    end
    
    it "requires a Barometer::Sun object" do
      lambda { Barometer::Sun.add_days!("invalid") }.should raise_error(ArgumentError)
      lambda { Barometer::Sun.add_days!(@sun) }.should_not raise_error(ArgumentError)
    end
    
    it "requires a Fixnum object" do
      lambda { Barometer::Sun.add_days!(@sun,1.1) }.should raise_error(ArgumentError)
      lambda { Barometer::Sun.add_days!(@sun,1) }.should_not raise_error(ArgumentError)
    end
    
    it "adds X days to both sun_rise and sun_set" do
      days_to_add = 2
      new_sun = Barometer::Sun.add_days!(@sun, days_to_add)
      new_sun.rise.should == @sun.rise + (60*60*24*days_to_add)
      new_sun.set.should == @sun.set + (60*60*24*days_to_add)
    end
    
  end
  
end