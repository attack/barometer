require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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

  describe "comparisons" do

    before(:each) do
      now = Time.local(2009,5,5,11,40,00)
      @mid_time = Data::LocalTime.new.parse(now)
      @early_time = Data::LocalTime.new.parse(now - (60*60*8))
      @late_time = Data::LocalTime.new.parse(now + (60*60*8))
    end

    describe "after_rise?" do

      it "requires a LocalTime object" do
        sun = Data::Sun.new(@early_time,@late_time)
        lambda { sun.after_rise? }.should raise_error(ArgumentError)
        lambda { sun.after_rise?("invalid") }.should raise_error(ArgumentError)
        lambda { sun.after_rise?(@mid_time) }.should_not raise_error(ArgumentError)
      end

      it "returns true when after sun rise" do
        sun = Data::Sun.new(@early_time,@late_time)
        sun.after_rise?(@mid_time).should be_true
      end

      it "returns false when before sun rise" do
        sun = Data::Sun.new(@mid_time,@late_time)
        sun.after_rise?(@early_time).should be_false
      end

    end

    describe "before_set?" do

      it "requires a LocalTime object" do
        sun = Data::Sun.new(@early_time,@late_time)
        lambda { sun.before_set? }.should raise_error(ArgumentError)
        lambda { sun.before_set?("invalid") }.should raise_error(ArgumentError)
        lambda { sun.before_set?(@mid_time) }.should_not raise_error(ArgumentError)
      end

      it "returns true when before sun set" do
        sun = Data::Sun.new(@early_time,@late_time)
        sun.before_set?(@mid_time).should be_true
      end

      it "returns false when before sun set" do
        sun = Data::Sun.new(@early_time,@mid_time)
        sun.before_set?(@late_time).should be_false
      end

    end

  end

end
