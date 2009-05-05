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
  
  # describe "when adjusting times" do
  #   
  #   before(:each) do
  #     @local_time_rise = Data::LocalTime.new.parse(Time.now)
  #     @local_time_set = Data::LocalTime.new.parse(Time.now + (60*60*8))
  #     @sun = Data::Sun.new(@local_time_rise, @local_time_set)
  #   end
  #   
  #   it "requires a Barometer::Sun object" do
  #     lambda { Data::Sun.add_days!("invalid") }.should raise_error(ArgumentError)
  #     lambda { Data::Sun.add_days!(@sun) }.should_not raise_error(ArgumentError)
  #   end
  #   
  #   it "requires a Fixnum object" do
  #     lambda { Data::Sun.add_days!(@sun,1.1) }.should raise_error(ArgumentError)
  #     lambda { Data::Sun.add_days!(@sun,1) }.should_not raise_error(ArgumentError)
  #   end
  #   
  #   it "adds X days to both sun_rise and sun_set" do
  #     days_to_add = 2
  #     new_sun = Data::Sun.add_days!(@sun, days_to_add)
  #     new_sun.rise.should == @sun.rise + (60*60*24*days_to_add)
  #     new_sun.set.should == @sun.set + (60*60*24*days_to_add)
  #   end
  #   
  # end
  
end