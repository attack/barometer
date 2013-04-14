require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Data::LocalDateTime do

  before(:each) do
    @y = 2009
    @mon = 5
    @d = 1
    @h = 12
    @m = 11
    @s = 10
  end

  describe "when initialized" do

    before(:each) do
      @datetime = Barometer::Data::LocalDateTime.new(@y,@mon,@d)
    end

    it "responds to hour" do
      @datetime.hour.should == 0
    end

    it "responds to min" do
      @datetime.min.should == 0
    end

    it "responds to sec" do
      @datetime.sec.should == 0
    end

    it "responds to year" do
      @datetime.year.should == @y
    end

    it "responds to month" do
      @datetime.month.should == @mon
    end

    it "responds to day" do
      @datetime.day.should == @d
    end

  end

  describe "conversion" do

    before(:each) do
      @datetime = Barometer::Data::LocalDateTime.new(@y,@mon,@d,@h,@m,@s)
    end

    it "converts to a DateTime object" do
      @datetime.is_a?(Barometer::Data::LocalDateTime)
      datetime = @datetime.to_dt
      datetime.is_a?(DateTime).should be_true
      datetime.year.should == @y
      datetime.mon.should == @mon
      datetime.day.should == @d
      datetime.hour.should == @h
      datetime.min.should == @m
      datetime.sec.should == @s
    end

    it "converts to a Date object" do
      @datetime.is_a?(Barometer::Data::LocalDateTime)
      date = @datetime.to_d
      date.is_a?(Date).should be_true
      date.year.should == @y
      date.mon.should == @mon
      date.day.should == @d
    end

    it "converts to a Time object" do
      @datetime.is_a?(Barometer::Data::LocalDateTime)
      time = @datetime.to_t
      time.is_a?(Time).should be_true
      time.hour.should == @h
      time.min.should == @m
      time.sec.should == @s
    end

  end

  describe "parsing" do

    before(:each) do
      @y = 2009
      @mon = 5
      @d = 1
      @h = 12
      @m = 11
      @s = 10
      @datetime = Barometer::Data::LocalDateTime.new(@y,@mon,@d,@h,@m,@s)
    end

    it "parses a Time object" do
      time = Time.local(@y,@mon,@d,@h,@m,@s)
      @datetime.parse(time)
      @datetime.year.should == @y
      @datetime.month.should == @mon
      @datetime.day.should == @d
      @datetime.hour.should == @h
      @datetime.min.should == @m
      @datetime.sec.should == @s
    end

    it "parses a DateTime object" do
      datetime = DateTime.new(@y,@mon,@d,@h,@m,@s)
      @datetime.parse(datetime)
      @datetime.year.should == @y
      @datetime.month.should == @mon
      @datetime.day.should == @d
      @datetime.hour.should == @h
      @datetime.min.should == @m
      @datetime.sec.should == @s
    end

    it "parses a Date object" do
      date = Date.civil(@y,@mon,@d)
      @datetime.parse(date)
      @datetime.year.should == @y
      @datetime.month.should == @mon
      @datetime.day.should == @d
    end

    it "parses a String" do
      string = "#{@y}-#{@mon}-#{@d} #{@h}:#{@m}:#{@s}"
      @datetime.parse(string)
      @datetime.year.should == @y
      @datetime.month.should == @mon
      @datetime.day.should == @d
      @datetime.hour.should == @h
      @datetime.min.should == @m
      @datetime.sec.should == @s
    end

    it "parses a String (using class method)" do
      string = "#{@y}-#{@mon}-#{@d} #{@h}:#{@m}:#{@s}"
      datetime = Barometer::Data::LocalDateTime.parse(string)
      datetime.year.should == @y
      datetime.month.should == @mon
      datetime.day.should == @d
      datetime.hour.should == @h
      datetime.min.should == @m
      datetime.sec.should == @s
    end

    it "returns nil when string contains no date/time info" do
      string = "Last Updated on , "
      datetime = Barometer::Data::LocalDateTime.parse(string)
      datetime.should be_nil
    end
  end

  describe "storing" do

    before(:each) do
      @datetime = Barometer::Data::LocalDateTime.new(@y,@mon,@d,@h,@m,@s)
    end

    it "requires Fixnum (accepts nil)" do
      invalid_data = "s"
      valid_data = 1
      lambda { @datetime.year = invalid_data }.should raise_error(ArgumentError)
      lambda { @datetime.year = valid_data }.should_not raise_error(ArgumentError)
      lambda { @datetime.year = nil }.should raise_error(ArgumentError)
      lambda { @datetime.month = invalid_data }.should raise_error(ArgumentError)
      lambda { @datetime.month = valid_data }.should_not raise_error(ArgumentError)
      lambda { @datetime.month = nil }.should raise_error(ArgumentError)
      lambda { @datetime.day = invalid_data }.should raise_error(ArgumentError)
      lambda { @datetime.day = valid_data }.should_not raise_error(ArgumentError)
      lambda { @datetime.day = nil }.should raise_error(ArgumentError)
    end

    it "rejects invalid dates during init" do
      lambda { Barometer::Data::LocalDateTime.new(2009,0,1) }.should raise_error(ArgumentError)
      lambda { Barometer::Data::LocalDateTime.new(2009,1,0) }.should raise_error(ArgumentError)
      lambda { Barometer::Data::LocalDateTime.new(2009,13,1) }.should raise_error(ArgumentError)
      lambda { Barometer::Data::LocalDateTime.new(2009,1,32) }.should raise_error(ArgumentError)
    end

    it "rejects invalid days" do
      lambda { @datetime.day = nil }.should raise_error(ArgumentError)
      lambda { @datetime.day = 32 }.should raise_error(ArgumentError)
      lambda { @datetime.day = "a" }.should raise_error(ArgumentError)
      lambda { @datetime.day = 0 }.should raise_error(ArgumentError)
    end

    it "rejects invalid months" do
      lambda { @datetime.month = nil }.should raise_error(ArgumentError)
      lambda { @datetime.month = 32 }.should raise_error(ArgumentError)
      lambda { @datetime.month = "a" }.should raise_error(ArgumentError)
      lambda { @datetime.month = 0 }.should raise_error(ArgumentError)
    end

    it "rejects invalid years" do
      lambda { @datetime.year = nil }.should raise_error(ArgumentError)
      lambda { @datetime.year = "a" }.should raise_error(ArgumentError)
    end

  end

    describe "retrieving" do

      before(:each) do
        @datetime = Barometer::Data::LocalDateTime.new(@y,@mon,@d,@h,@m,@s)
      end

      it "returns pretty string" do
        @datetime.to_s.should == "2009-05-01"
        @datetime.to_s(true).should == "2009-05-01 12:11:10 pm"
      end

    end

  describe "comparators" do

    before(:each) do
      @datetime_low = Barometer::Data::LocalDateTime.new(2009,5,4,0,0,1)
      @datetime_mid = Barometer::Data::LocalDateTime.new(2009,5,5,12,0,0)
      @datetime_high = Barometer::Data::LocalDateTime.new(2009,5,6,23,59,59)
    end

    it "counts days" do
      Barometer::Data::LocalDateTime.new(0,1,1,0,0,0)._total_days.should == 1
      Barometer::Data::LocalDateTime.new(0,2,1,0,0,0)._total_days.should == 32
      Barometer::Data::LocalDateTime.new(1,1,1,0,0,0)._total_days.should == 367
    end

    it "defines <=>" do
      Barometer::Data::LocalDateTime.method_defined?("<=>").should be_true
      (@datetime_low <=> @datetime_high).should == -1
      (@datetime_high <=> @datetime_low).should == 1
      (@datetime_mid <=> @datetime_mid).should == 0
    end

    it "compares to a Time object" do
      time = Time.local(2009,5,5,12,0,0)
      (@datetime_low <=> time).should == -1
      (@datetime_high <=> time).should == 1
      (@datetime_mid <=> time).should == 0
    end

    it "compares to a DateTime object" do
      time = DateTime.new(2009,5,5,12,0,0)
      (@datetime_low <=> time).should == -1
      (@datetime_high <=> time).should == 1
      (@datetime_mid <=> time).should == 0
    end

    it "compares to a Date object" do
      date = Date.civil(2009,5,5)
      (@datetime_low <=> date).should == -1
      (@datetime_high <=> date).should == 1
      (@datetime_mid <=> date).should == 0
    end

    it "compares to a String object" do
      time = "2009-5-5 12:00:00"
      (@datetime_low <=> time).should == -1
      (@datetime_high <=> time).should == 1
      (@datetime_mid <=> time).should == 0
    end

    it "compares to a Barometer::Data::LocalTime object" do
      local_time = Barometer::Data::LocalTime.new(12,0,0)
      (@datetime_low <=> local_time).should == -1
      (@datetime_high <=> local_time).should == 1
      (@datetime_mid <=> local_time).should == 0
    end

  end

end
