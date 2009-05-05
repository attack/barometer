require 'spec_helper'

describe "Data::Zone" do
  
  describe "and class methods" do
    
    it "responds to now and returns Time object" do
      Data::Zone.respond_to?("now").should be_true
      Data::Zone.now.is_a?(Time).should be_true
    end

    it "responds to today and returns Date object" do
      Data::Zone.respond_to?("today").should be_true
      Data::Zone.today.is_a?(Date).should be_true
    end
    
  end
  
  describe "when initialized" do
    
    before(:each) do
      @utc = Time.now.utc
      @timezone = "Europe/Paris"
      @zone = Data::Zone.new(@timezone)
    end
    
    it "responds to timezone" do
      @zone.timezone.should_not be_nil
      @zone.timezone.should == @timezone
    end
    
    it "responds to tz" do
      lambda { Data::Zone.new("invalid timezone") }.should raise_error(TZInfo::InvalidTimezoneIdentifier)
      
      zone = Data::Zone.new(@timezone)
      zone.tz.should_not be_nil
    end
    
    it "responds to code" do
      @zone.respond_to?("code").should be_true
      zone = Data::Zone.new(@timezone)
      zone.tz = nil
      zone.tz.should be_nil
      zone.code.should == ""
      
      zone = Data::Zone.new(@timezone)
      zone.code.should == "CEST"
    end
    
    it "responds to dst?" do
      @zone.respond_to?("dst?").should be_true
      zone = Data::Zone.new(@timezone)
      zone.tz = nil
      zone.tz.should be_nil
      zone.dst?.should be_nil
    end
    
    it "responds to now" do
      @zone.respond_to?("now").should be_true
      @zone.now.is_a?(Time).should be_true
    end

    it "responds to today" do
      @zone.respond_to?("today").should be_true
      @zone.today.is_a?(Date).should be_true
    end
    
    it "responds to now" do
      Data::Zone.respond_to?("now").should be_true
    end
    
    it "responds to today" do
      Data::Zone.respond_to?("today").should be_true
    end
    
    it "converts local_time to utc" do
      local_time = Time.now.utc
      utc_time = @zone.local_to_utc(local_time)
      
      offset =  @zone.tz.period_for_utc(local_time).utc_total_offset
      utc_time.should == (local_time - offset)
    end
    
    it "converts utc to local_time" do
      utc_time = Time.now.utc
      local_time = @zone.utc_to_local(utc_time)
      
      offset =  @zone.tz.period_for_utc(local_time).utc_total_offset
      utc_time.should == (local_time - offset)
    end
    
  end
  
  describe "when manipulating times" do
    
    it "converts a time to utc based on TimeZone Short Code" do
      target_zone = "PDT"
      target_offset = Time.zone_offset("PDT")
      target_time = Time.now
      local_time = target_time
      local_offset = Time.zone_offset(local_time.zone)
      
      # converting two times (ie 6am PDT and 6am MDT) to UTC should result
      # in two UTC times that are off by the same offset
      original_difference = local_offset - target_offset
      
      target_utc_time = Data::Zone.code_to_utc(target_time, target_zone)
      local_utc_time = local_time.utc
      
      (target_utc_time - local_time.utc).to_i.should == original_difference.to_i
    end
      
    it "merges a date and a time to one utc time (biased by TimeZone Short Code)" do
      merge_date = "1 March 1990"
      merge_time = "5:35 am"
      merge_zonecode = "UTC"
      
      date = Date.parse(merge_date)
      time = Time.parse(merge_time)
      
      utc_time = Data::Zone.merge(merge_time, merge_date, merge_zonecode)
      
      utc_time.year.should == date.year
      utc_time.month.should == date.month
      utc_time.day.should == date.day
      utc_time.hour.should == time.hour
      utc_time.min.should == time.min
      utc_time.sec.should == time.sec
    end
    
  end
  
end