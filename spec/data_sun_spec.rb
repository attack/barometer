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
    
  end
  
end