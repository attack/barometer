require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Data::LocalTime do

  describe "when initialized" do

    before(:each) do
      @time = Barometer::Data::LocalTime.new
    end

    it "responds to hour" do
      @time.hour.should == 0
    end

    it "responds to min" do
      @time.min.should == 0
    end

    it "responds to sec" do
      @time.sec.should == 0
    end

  end

  describe "conversion" do

    before(:each) do
      @h = 12
      @m = 11
      @s = 10
      @time = Barometer::Data::LocalTime.new(@h,@m,@s)
    end

    it "converts to a Time object" do
      @time.is_a?(Barometer::Data::LocalTime)
      @time.to_t.is_a?(Time).should be_true
      @time.hour.should == @h
      @time.min.should == @m
      @time.sec.should == @s
    end

  end

  describe "parsing" do

    before(:each) do
      @h = 12
      @m = 11
      @s = 10
      @time = Barometer::Data::LocalTime.new(@h,@m,@s)
    end

    it "parses a Time object" do
      time = Time.local(2009,1,1,@h,@m,@s)
      @time.parse(time)
      @time.hour.should == @h
      @time.min.should == @m
      @time.sec.should == @s
    end

    it "parses a DateTime object" do
      time = DateTime.new(2009,1,1,@h,@m,@s)
      @time.parse(time)
      @time.hour.should == @h
      @time.min.should == @m
      @time.sec.should == @s
    end

    it "parses a String" do
      time = "#{@h}:#{@m}:#{@s}"
      @time.parse(time)
      @time.hour.should == @h
      @time.min.should == @m
      @time.sec.should == @s
    end

    it "parses a String (using class method)" do
      time = "#{@h}:#{@m}:#{@s}"
      time = Barometer::Data::LocalTime.parse(time)
      time.hour.should == @h
      time.min.should == @m
      time.sec.should == @s
    end

  end

  describe "storing" do

    before(:each) do
      @h = 12
      @m = 11
      @s = 10
      @time = Barometer::Data::LocalTime.new(@h,@m,@s)
    end

    it "requires Fixnum (accepts nil)" do
      invalid_data = "s"
      valid_data = 1
      lambda { @time.hour = invalid_data }.should raise_error(ArgumentError)
      lambda { @time.hour = valid_data }.should_not raise_error(ArgumentError)
      lambda { @time.hour = nil }.should_not raise_error(ArgumentError)
      lambda { @time.min = invalid_data }.should raise_error(ArgumentError)
      lambda { @time.min = valid_data }.should_not raise_error(ArgumentError)
      lambda { @time.min = nil }.should_not raise_error(ArgumentError)
      lambda { @time.sec = invalid_data }.should raise_error(ArgumentError)
      lambda { @time.sec = valid_data }.should_not raise_error(ArgumentError)
      lambda { @time.sec = nil }.should_not raise_error(ArgumentError)
    end

    it "rolls over seconds" do
      time = Barometer::Data::LocalTime.new(0,0,60)
      time.sec.should == 0
      time.min.should == 1
    end

    it "rolls over minutes" do
      time = Barometer::Data::LocalTime.new(0,60,0)
      time.min.should == 0
      time.hour.should == 1
    end

    it "rolls over hours" do
      time = Barometer::Data::LocalTime.new(24,0,0)
      time.sec.should == 0
      time.min.should == 0
      time.hour.should == 0
    end

    it "rolls over everything" do
      time = Barometer::Data::LocalTime.new(50,600,601)
      time.sec.should == 1
      time.min.should == 10
      time.hour.should == 12
    end

    it "add seconds" do
      time = Barometer::Data::LocalTime.new(0,0,0)
      time = time + 61
      time.sec.should == 1
      time.min.should == 1
    end

  end

  describe "retrieving" do

    before(:each) do
      @h = 6
      @m = 30
      @s = 20
      @time = Barometer::Data::LocalTime.new(@h,@m,@s)
    end

    it "returns pretty string" do
      @time.to_s.should == "06:30 am"
      @time.to_s(true).should == "06:30:20 am"
    end

  end

  describe "comparators" do

    before(:each) do
      @time_low = Barometer::Data::LocalTime.new(0,0,1)
      @time_mid = Barometer::Data::LocalTime.new(12,0,0)
      @time_high = Barometer::Data::LocalTime.new(23,59,59)
    end

    it "defines <=>" do
      Barometer::Data::LocalTime.method_defined?("<=>").should be_true
      (@time_low <=> @time_high).should == -1
      (@time_high <=> @time_low).should == 1
      (@time_mid <=> @time_mid).should == 0
    end

    it "compares to a Time object" do
      time = Time.local(2009,1,1,12,0,0)
      (@time_low <=> time).should == -1
      (@time_high <=> time).should == 1
      (@time_mid <=> time).should == 0
    end

    it "compares to a DateTime object" do
      time = DateTime.new(2009,1,1,12,0,0)
      (@time_low <=> time).should == -1
      (@time_high <=> time).should == 1
      (@time_mid <=> time).should == 0
    end

    it "compares to a String object" do
      time = "12:00:00"
      (@time_low <=> time).should == -1
      (@time_high <=> time).should == 1
      (@time_mid <=> time).should == 0
    end

  end

  describe "math" do

    it "counts the total seconds" do
      Barometer::Data::LocalTime.new(0,0,1).total_seconds.should == 1
      Barometer::Data::LocalTime.new(0,1,0).total_seconds.should == (1*60)
      Barometer::Data::LocalTime.new(1,0,0).total_seconds.should == (1*60*60)
    end

    it "provides a difference" do
      a = Barometer::Data::LocalTime.new(0,0,1)
      b = Barometer::Data::LocalTime.new(1,0,0)
      diff = (1*60*60) - 1
      a.diff(b).should == diff
      b.diff(a).should == diff
    end

    it "adds time" do
      a = Barometer::Data::LocalTime.new(0,0,1)
      b = Barometer::Data::LocalTime.new(1,0,0)
      c = (a + b)
      c.is_a?(Barometer::Data::LocalTime).should be_true
      c.should == Barometer::Data::LocalTime.new(1,0,1)

      b = Barometer::Data::LocalTime.new(1,0,0)
      (b + 1).should == Barometer::Data::LocalTime.new(1,0,1)
    end

    it "subtracts time" do
      a = Barometer::Data::LocalTime.new(0,0,1)
      b = Barometer::Data::LocalTime.new(1,0,0)
      c = (b - a)
      c.is_a?(Barometer::Data::LocalTime).should be_true
      c.should == Barometer::Data::LocalTime.new(0,59,59)

      b = Barometer::Data::LocalTime.new(1,0,0)
      (b - 1).should == Barometer::Data::LocalTime.new(0,59,59)
    end

  end

end
