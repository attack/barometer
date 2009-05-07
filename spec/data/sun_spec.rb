require 'spec_helper'

describe "Data::Sun" do
  
  describe "when initialized" do
    
    before(:each) do
      @sun = Data::Sun.new
      @local_time_rise = Data::LocalTime.new.parse(Time.now)
      @local_time_set = Data::LocalTime.new.parse(Time.now + (60*60*8))
    end
    
    it "responds to rise" do
      @sun.respond_to?("rise").should be_true
    end
    
    it "responds to set" do
      @sun.respond_to?("set").should be_true
    end
    
    it "sets sunrise" do
      sun = Data::Sun.new(@local_time_rise,@local_time_set)
      sun.rise.should == @local_time_rise
    end
    
    it "sets sunset" do
      sun = Data::Sun.new(@local_time_rise,@local_time_set)
      sun.set.should == @local_time_set
    end
    
    it "requires Data::LocalTime for sunrise" do
      lambda { Data::Sun.new("",@local_time_set) }.should raise_error(ArgumentError)
      lambda { Data::Sun.new(@local_time_rise,@local_time_set) }.should_not raise_error(ArgumentError)
    end
    
    it "requires Data::LocalTime for sunset" do
      lambda { Data::Sun.new(@local_time_rise,"") }.should raise_error(ArgumentError)
      lambda { Data::Sun.new(@local_time_rise,@local_time_set) }.should_not raise_error(ArgumentError)
    end
    
    it "responds to nil?" do
      @sun.nil?.should be_true
      sun = Data::Sun.new(@local_time_rise, @local_time_set)
      sun.nil?.should be_false
    end
    
  end
  
end