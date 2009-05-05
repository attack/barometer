require 'spec_helper'

describe "Data::LocalDateTime" do
  
  describe "when initialized" do
    
    before(:each) do
      @datetime = Data::LocalDateTime.new
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
      @datetime.year.should == 0
    end
    
    it "responds to month" do
      @datetime.month.should == 0
    end
    
    it "responds to day" do
      @datetime.day.should == 0
    end
    
  end
  
  describe "conversion" do
    
    before(:each) do
      @y = 2009
      @mon = 5
      @d = 1
      @h = 12
      @m = 11
      @s = 10
      @datetime = Data::LocalDateTime.new(@y,@mon,@d,@h,@m,@s)
    end
  
    it "converts to a DateTime object" do
      @datetime.is_a?(Data::LocalDateTime)
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
      @datetime.is_a?(Data::LocalDateTime)
      date = @datetime.to_d
      date.is_a?(Date).should be_true
      date.year.should == @y
      date.mon.should == @mon
      date.day.should == @d
    end

    it "converts to a Time object" do
      @datetime.is_a?(Data::LocalDateTime)
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
      @datetime = Data::LocalDateTime.new(@y,@mon,@d,@h,@m,@s)
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
      datetime = Data::LocalDateTime.parse(string)
      datetime.year.should == @y
      datetime.month.should == @mon
      datetime.day.should == @d
      datetime.hour.should == @h
      datetime.min.should == @m
      datetime.sec.should == @s
    end
    
  end
  
  # describe "storing" do
  #   
  #   before(:each) do
  #     @h = 12
  #     @m = 11
  #     @s = 10
  #     @time = Data::LocalTime.new(@h,@m,@s)
  #   end
  #   
  #   it "requires Fixnum (accepts nil)" do
  #     invalid_data = "s"
  #     valid_data = 1
  #     lambda { @time.hour = invalid_data }.should raise_error(ArgumentError)
  #     lambda { @time.hour = valid_data }.should_not raise_error(ArgumentError)
  #     lambda { @time.hour = nil }.should_not raise_error(ArgumentError)
  #     lambda { @time.min = invalid_data }.should raise_error(ArgumentError)
  #     lambda { @time.min = valid_data }.should_not raise_error(ArgumentError)
  #     lambda { @time.min = nil }.should_not raise_error(ArgumentError)
  #     lambda { @time.sec = invalid_data }.should raise_error(ArgumentError)
  #     lambda { @time.sec = valid_data }.should_not raise_error(ArgumentError)
  #     lambda { @time.sec = nil }.should_not raise_error(ArgumentError)
  #   end
  #   
  #   it "rolls over seconds" do
  #     time = Data::LocalTime.new(0,0,60)
  #     time.sec.should == 0
  #     time.min.should == 1
  #   end
  #   
  #   it "rolls over minutes" do
  #     time = Data::LocalTime.new(0,60,0)
  #     time.min.should == 0
  #     time.hour.should == 1
  #   end
  #   
  #   it "rolls over hours" do
  #     time = Data::LocalTime.new(24,0,0)
  #     time.sec.should == 0
  #     time.min.should == 0
  #     time.hour.should == 0
  #   end
  #   
  #   it "rolls over everything" do
  #     time = Data::LocalTime.new(50,600,601)
  #     time.sec.should == 1
  #     time.min.should == 10
  #     time.hour.should == 12
  #   end
  #   
  #   it "add seconds" do
  #     time = Data::LocalTime.new(0,0,0)
  #     time = time + 61
  #     time.sec.should == 1
  #     time.min.should == 1
  #   end
  #   
  # end
  
  # describe "retrieving" do
  #   
  #   before(:each) do
  #     @h = 6
  #     @m = 30
  #     @s = 20
  #     @time = Data::LocalTime.new(@h,@m,@s)
  #   end
  #   
  #   it "returns pretty string" do
  #     @time.to_s.should == "06:30 am"
  #     @time.to_s(true).should == "06:30:20 am"
  #   end
  #   
  # end
  
  describe "comparators" do
    
    before(:each) do
      @datetime_low = Data::LocalDateTime.new(2009,5,4,0,0,1)
      @datetime_mid = Data::LocalDateTime.new(2009,5,5,12,0,0)
      @datetime_high = Data::LocalDateTime.new(2009,5,6,23,59,59)
    end
    
    it "defines <=>" do
      Data::LocalDateTime.method_defined?("<=>").should be_true
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
    
    it "compares to a Data::LocalTime object" do
      local_time = Data::LocalTime.new(12,0,0)
      (@datetime_low <=> local_time).should == -1
      (@datetime_high <=> local_time).should == 1
      (@datetime_mid <=> local_time).should == 0
    end
    
  end
  
  # describe "math" do
  #   
  #   it "counts the total seconds" do
  #     Data::LocalTime.new(0,0,1).total_seconds.should == 1
  #     Data::LocalTime.new(0,1,0).total_seconds.should == (1*60)
  #     Data::LocalTime.new(1,0,0).total_seconds.should == (1*60*60)
  #   end
  #   
  #   it "provides a difference" do
  #     a = Data::LocalTime.new(0,0,1)
  #     b = Data::LocalTime.new(1,0,0)
  #     diff = (1*60*60) - 1
  #     a.diff(b).should == diff
  #     b.diff(a).should == diff
  #   end
  #   
  #   it "adds time" do
  #     a = Data::LocalTime.new(0,0,1)
  #     b = Data::LocalTime.new(1,0,0)
  #     c = (a + b)
  #     c.is_a?(Data::LocalTime).should be_true
  #     c.should == Data::LocalTime.new(1,0,1)
  #     
  #     b = Data::LocalTime.new(1,0,0)
  #     (b + 1).should == Data::LocalTime.new(1,0,1)
  #   end
  #   
  #   it "subtracts time" do
  #     a = Data::LocalTime.new(0,0,1)
  #     b = Data::LocalTime.new(1,0,0)
  #     c = (b - a)
  #     c.is_a?(Data::LocalTime).should be_true
  #     c.should == Data::LocalTime.new(0,59,59)
  #     
  #     b = Data::LocalTime.new(1,0,0)
  #     (b - 1).should == Data::LocalTime.new(0,59,59)
  #   end
  #   
  # end
  
end