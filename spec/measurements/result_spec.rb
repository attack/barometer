require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Result Measurement" do

  describe "when initialized" do

    before(:each) do
      @result = Measurement::Result.new
    end

    it "responds to temperature" do
      @result.temperature.should be_nil
    end

    it "responds to dew_point" do
      @result.dew_point.should be_nil
    end

    it "responds to heat_index" do
      @result.heat_index.should be_nil
    end

    it "responds to wind_chill" do
      @result.wind_chill.should be_nil
    end

    it "responds to pressure" do
      @result.pressure.should be_nil
    end

    it "responds to visibility" do
      @result.pressure.should be_nil
    end

    it "responds to current_at" do
      @result.current_at.should be_nil
    end

    it "responds to updated_at" do
      @result.updated_at.should be_nil
    end

    it "responds to date" do
      @result.date.should be_nil
    end

    it "responds to low" do
      @result.low.should be_nil
    end

    it "responds to high" do
      @result.high.should be_nil
    end

    it "responds to pop" do
      @result.pop.should be_nil
    end

    it "responds to valid_start_date" do
      @result.valid_start_date.should be_nil
    end

    it "responds to valid_end_date" do
      @result.valid_end_date.should be_nil
    end

    it "responds to description" do
      @result.description.should be_nil
    end

    it "responds to humidity" do
      @result.humidity.should be_nil
    end

    it "responds to icon" do
      @result.icon.should be_nil
    end

    it "responds to condition" do
      @result.condition.should be_nil
    end

    it "responds to wind" do
      @result.wind.should be_nil
    end

    it "responds to sun" do
      @result.sun.should be_nil
    end

    it "responds to metric" do
      @result.metric.should be_true
    end

    it "responds to metric?" do
      @result.metric?.should be_true
      @result.metric = false
      @result.metric?.should be_false
    end

  end

  describe "when writing data" do

    before(:each) do
      @result = Measurement::Result.new
    end

    it "only accepts Data::Temperature for temperature" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @result.temperature = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @result.temperature = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::Temperature for dew_point" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @result.dew_point = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @result.dew_point = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::Temperature for heat_index" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @result.heat_index = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @result.heat_index = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::Temperature for wind_chill" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @result.wind_chill = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @result.wind_chill = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::Pressure for pressure" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Pressure
      lambda { @result.pressure = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Pressure.new
      valid_data.class.should == Data::Pressure
      lambda { @result.pressure = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::Distance for visibility" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Distance
      lambda { @result.visibility = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Distance.new
      valid_data.class.should == Data::Distance
      lambda { @result.visibility = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::LocalTime || Data::LocalDateTime current_at" do
      invalid_data = 1
      invalid_data.class.should_not == Data::LocalTime
      invalid_data.class.should_not == Data::LocalDateTime
      lambda { @result.current_at = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::LocalTime.new
      valid_data.class.should == Data::LocalTime
      lambda { @result.current_at = valid_data }.should_not raise_error(ArgumentError)

      valid_data = Data::LocalDateTime.new(2009,1,1)
      valid_data.class.should == Data::LocalDateTime
      lambda { @result.current_at = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::LocalTime || Data::LocalDateTime current_at" do
      invalid_data = 1
      invalid_data.class.should_not == Data::LocalTime
      invalid_data.class.should_not == Data::LocalDateTime
      lambda { @result.updated_at = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::LocalTime.new
      valid_data.class.should == Data::LocalTime
      lambda { @result.updated_at = valid_data }.should_not raise_error(ArgumentError)

      valid_data = Data::LocalDateTime.new(2009,1,1)
      valid_data.class.should == Data::LocalDateTime
      lambda { @result.updated_at = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Date for date" do
      invalid_data = 1
      invalid_data.class.should_not == Date
      lambda { @result.date = invalid_data }.should raise_error(ArgumentError)

      valid_data = Date.new
      valid_data.class.should == Date
      lambda { @result.date = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::Temperature for high" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @result.high = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @result.high = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::Temperature for low" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @result.low = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @result.low = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Fixnum for pop" do
      invalid_data = "test"
      invalid_data.class.should_not == Fixnum
      lambda { @result.pop = invalid_data }.should raise_error(ArgumentError)

      valid_data = 50
      valid_data.class.should == Fixnum
      lambda { @result.pop = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::LocalDateTime for valid_start_date" do
      invalid_data = 1
      invalid_data.class.should_not == Data::LocalDateTime
      lambda { @result.valid_start_date = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::LocalDateTime.new(2009,1,1)
      valid_data.class.should == Data::LocalDateTime
      lambda { @result.valid_start_date = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::LocalDateTime for valid_end_date" do
      invalid_data = 1
      invalid_data.class.should_not == Data::LocalDateTime
      lambda { @result.valid_end_date = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::LocalDateTime.new(2009,1,1)
      valid_data.class.should == Data::LocalDateTime
      lambda { @result.valid_end_date = valid_data }.should_not raise_error(ArgumentError)
    end

    it "sets valid_start_date and valid_end_date if given date" do
      forecast = Measurement::Result.new
      forecast.valid_start_date.should be_nil
      forecast.valid_end_date.should be_nil
      date = Date.new(2009,05,05)
      forecast.date = date
      forecast.valid_start_date.should_not be_nil
      forecast.valid_start_date.year.should == date.year
      forecast.valid_start_date.month.should == date.month
      forecast.valid_start_date.day.should == date.day
      forecast.valid_start_date.hour.should == 0
      forecast.valid_start_date.min.should == 0
      forecast.valid_start_date.sec.should == 0

      forecast.valid_end_date.should_not be_nil
      forecast.valid_end_date.year.should == date.year
      forecast.valid_end_date.month.should == date.month
      forecast.valid_end_date.day.should == date.day
      forecast.valid_end_date.hour.should == 23
      forecast.valid_end_date.min.should == 59
      forecast.valid_end_date.sec.should == 59
    end

    it "returns true if the valid_date range includes the given date" do
      forecast = Measurement::Result.new
      forecast.date = Date.new(2009,05,05)
      forecast.for_datetime?(Data::LocalDateTime.new(2009,5,5,12,0,0)).should be_true
    end

    it "returns false if the valid_date range excludes the given date" do
      forecast = Measurement::Result.new
      forecast.date = Date.new(2009,05,05)
      forecast.for_datetime?(Data::LocalDateTime.new(2009,5,4,12,0,0)).should be_false
    end

    it "only accepts Fixnum or Float for humidity" do
      invalid_data = "invalid"
      invalid_data.class.should_not == Fixnum
      invalid_data.class.should_not == Float
      lambda { @result.humidity = invalid_data }.should raise_error(ArgumentError)

      valid_data = 1.to_i
      valid_data.class.should == Fixnum
      lambda { @result.humidity = valid_data }.should_not raise_error(ArgumentError)

      valid_data = 1.0.to_f
      valid_data.class.should == Float
      lambda { @result.humidity = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts String for icon" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @result.icon = invalid_data }.should raise_error(ArgumentError)

      valid_data = "valid"
      valid_data.class.should == String
      lambda { @result.icon = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts String for condition" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @result.condition = invalid_data }.should raise_error(ArgumentError)

      valid_data = "valid"
      valid_data.class.should == String
      lambda { @result.condition = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::Speed for wind" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Speed
      lambda { @result.wind = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Speed.new
      valid_data.class.should == Data::Speed
      lambda { @result.wind = valid_data }.should_not raise_error(ArgumentError)
    end

    it "only accepts Data::Sun for sun" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Sun
      lambda { @result.sun = invalid_data }.should raise_error(ArgumentError)

      valid_data = Data::Sun.new
      valid_data.class.should == Data::Sun
      lambda { @result.sun = valid_data }.should_not raise_error(ArgumentError)
    end

  end

  describe "method missing" do

    before(:each) do
      @result = Measurement::Result.new
    end

    it "responds to method + ?" do
      valid_method = "humidity"
      @result.respond_to?(valid_method).should be_true
      lambda { @result.send(valid_method + "?") }.should_not raise_error(NoMethodError)
    end

    it "ignores non_method + ?" do
      invalid_method = "humid"
      @result.respond_to?(invalid_method).should be_false
      lambda { @result.send(invalid_method + "?") }.should raise_error(NoMethodError)
    end

    it "returns true if set" do
      @result.humidity = 10
      @result.humidity.should_not be_nil
      @result.humidity?.should be_true
    end

    it "returns false if not set" do
      @result.humidity.should be_nil
      @result.humidity?.should be_false
    end

  end

  describe "answer simple questions, like" do

    before(:each) do
      @result = Measurement::Result.new
      @result.temperature = Data::Temperature.new
      @result.temperature << 5
      @dew_point = Data::Temperature.new
      @dew_point << 10
    end

    describe "windy?" do

      before(:each) do
        @wind = Data::Speed.new
        @wind << 11
      end

      it "requires real threshold number (or nil)" do
        lambda { @result.windy?("invalid") }.should raise_error(ArgumentError)
        lambda { @result.windy? }.should_not raise_error(ArgumentError)
        lambda { @result.windy?(10) }.should_not raise_error(ArgumentError)
      end

      it "returns nil when no wind" do
        @result.wind?.should be_false
        @result.windy?.should be_nil
        @result.wind = @wind
        @result.wind?.should be_true
        @result.windy?.should_not be_nil
      end

      it "return true when current wind over threshold" do
        @result.wind = @wind
        @result.windy?.should be_true
        @result.windy?(10).should be_true
      end

      it "return false when current wind under threshold" do
        @result.wind = @wind
        @result.windy?(15).should be_false
      end

    end

    describe "day?" do

      before(:each) do
        @early_time = Data::LocalTime.parse("6:00 am")
        @mid_time = Data::LocalTime.parse("11:00 am")
        @late_time = Data::LocalTime.parse("8:00 pm")
        @sun = Data::Sun.new(@early_time, @late_time)

      end

      it "requires Data::LocalTime object" do
        @result.sun = @sun
        lambda { @result.day?("invalid") }.should raise_error(ArgumentError)
        lambda { @result.day? }.should raise_error(ArgumentError)
        lambda { @result.day?(@mid_time) }.should_not raise_error(ArgumentError)
      end

      it "returns nil when no sun" do
        @result.sun?.should be_false
        @result.day?(@mid_time).should be_nil
        @result.sun = @sun
        @result.sun?.should be_true
        @result.day?(@mid_time).should_not be_nil
      end

      it "return true when time between rise and set" do
        @result.sun = @sun
        @result.day?(@mid_time).should be_true
      end

      it "return false when time before rise or after set" do
        sun = Data::Sun.new(@mid_time, @late_time)
        @result.sun = sun
        @result.day?(@early_time).should be_false

        sun = Data::Sun.new(@early_time, @mid_time)
        @result.sun = sun
        @result.day?(@late_time).should be_false
      end

    end

    describe "wet?" do

      describe "wet_by_humidity?" do

        it "requires real threshold number (or nil)" do
          lambda { @result.send("_wet_by_humidity?","invalid") }.should raise_error(ArgumentError)
          lambda { @result.send("_wet_by_humidity?") }.should_not raise_error(ArgumentError)
          lambda { @result.send("_wet_by_humidity?",99) }.should_not raise_error(ArgumentError)
        end

        it "returns nil when no humidity" do
          @result.humidity?.should be_false
          @result.send("_wet_by_humidity?").should be_nil
          @result.wet?(nil,99).should be_nil
          @result.humidity = 100
          @result.humidity?.should be_true
          @result.send("_wet_by_humidity?").should_not be_nil
          @result.wet?(nil,99).should_not be_nil
        end

        it "return true when current humidity over threshold" do
          @result.humidity = 100
          @result.send("_wet_by_humidity?").should be_true
          @result.send("_wet_by_humidity?",99).should be_true
          @result.wet?(nil,99).should be_true
        end

        it "return false when current humidity under threshold" do
          @result.humidity = 98
          @result.send("_wet_by_humidity?",99).should be_false
          @result.wet?(nil,99).should be_false
        end

      end

      describe "wet_by_icon?" do

        before(:each) do
          @wet_icons = %w(rain thunderstorm)
        end

        it "requires Array (or nil)" do
          lambda { @result.send("_wet_by_icon?","invalid") }.should raise_error(ArgumentError)
          lambda { @result.send("_wet_by_icon?") }.should_not raise_error(ArgumentError)
          lambda { @result.send("_wet_by_icon?",@wet_icons) }.should_not raise_error(ArgumentError)
        end

        it "returns nil when no icon or Array" do
          @result.icon?.should be_false
          @result.send("_wet_by_icon?",@wet_icons).should be_nil
          @result.wet?(@wet_icons).should be_nil
          @result.icon = "rain"
          @result.icon?.should be_true
          @result.send("_wet_by_icon?").should be_nil
          @result.send("_wet_by_icon?",@wet_icons).should_not be_nil
          @result.wet?(@wet_icons).should_not be_nil
        end

        it "return true when current icon indicates wet" do
          @result.icon = "rain"
          @result.send("_wet_by_icon?",@wet_icons).should be_true
          @result.wet?(@wet_icons).should be_true
        end

        it "return false when current icon does NOT indicate wet" do
          @result.icon = "sun"
          @result.send("_wet_by_icon?",@wet_icons).should be_false
          @result.wet?(@wet_icons).should be_false
        end

      end

      describe "wet_by_dewpoint?" do

        it "returns nil when no dewpoint" do
          @result.dew_point?.should be_false
          @result.send("_wet_by_dewpoint?").should be_nil
          @result.wet?.should be_nil
          @result.dew_point = @dew_point
          @result.dew_point?.should be_true
          @result.send("_wet_by_dewpoint?").should_not be_nil
          @result.wet?.should_not be_nil
        end

        it "return true when current dewpoint over temperature" do
          @result.dew_point = @dew_point
          @result.send("_wet_by_dewpoint?").should be_true
          @result.wet?.should be_true
        end

        it "return false when current dewpoint under temperature" do
          @result.temperature << 15
          @result.dew_point = @dew_point
          @result.send("_wet_by_dewpoint?").should be_false
          @result.wet?.should be_false
        end

      end

      describe "wet_by_pop?" do

        it "requires real threshold number (or nil)" do
          lambda { @result.send("_wet_by_pop?","invalid") }.should raise_error(ArgumentError)
          lambda { @result.send("_wet_by_pop?") }.should_not raise_error(ArgumentError)
          lambda { @result.send("_wet_by_pop?",50) }.should_not raise_error(ArgumentError)
        end

        it "returns nil when no pop" do
          @result.pop?.should be_false
          @result.send("_wet_by_pop?",50).should be_nil
          @result.wet?.should be_nil
          @result.pop = 60
          @result.pop?.should be_true
          @result.send("_wet_by_pop?",50).should_not be_nil
          @result.wet?.should_not be_nil
        end

        it "return true when current pop over threshold" do
          @result.pop = 60
          @result.send("_wet_by_pop?",50).should be_true
          @result.wet?.should be_true
        end

        it "return false when current pop under threshold" do
          @result.pop = 40
          @result.send("_wet_by_pop?",50).should be_false
          @result.wet?.should be_false
        end

      end

    end

    describe "sunny?" do

      describe "sunny_by_icon?" do

        before(:each) do
          @sunny_icons = %w(sunny clear)
          @early_time = Data::LocalTime.parse("6:00 am")
          @mid_time = Data::LocalTime.parse("11:00 am")
          @late_time = Data::LocalTime.parse("8:00 pm")
          @sun = Data::Sun.new(@early_time, @late_time)

          @result.sun = @sun
        end

        it "requires Array (or nil)" do
          lambda { @result.send("_sunny_by_icon?","invalid") }.should raise_error(ArgumentError)
          lambda { @result.send("_sunny_by_icon?") }.should_not raise_error(ArgumentError)
          lambda { @result.send("_sunny_by_icon?",@sunny_icons) }.should_not raise_error(ArgumentError)
        end

        it "returns nil when no icon or Array" do
          @result.icon?.should be_false
          @result.send("_sunny_by_icon?",@sunny_icons).should be_nil
          @result.sunny?(@mid_time,@sunny_icons).should be_nil
          @result.icon = "sunny"
          @result.icon?.should be_true
          @result.send("_sunny_by_icon?").should be_nil
          @result.send("_sunny_by_icon?",@sunny_icons).should_not be_nil
          @result.sun?(@mid_time,@sunny_icons).should_not be_nil
        end

        it "returns true when current icon indicates sunny" do
          @result.icon = "sunny"
          @result.send("_sunny_by_icon?",@sunny_icons).should be_true
          @result.sunny?(@mid_time,@sunny_icons).should be_true
        end

        it "returns false when current icon does NOT indicate sunny" do
          @result.icon = "rain"
          @result.send("_sunny_by_icon?",@sunny_icons).should be_false
          @result.sunny?(@mid_time,@sunny_icons).should be_false
        end

        it "returns false when night" do
          @result.icon = "sunny"
          @result.send("_sunny_by_icon?",@sunny_icons).should be_true
          @result.sunny?(@mid_time,@sunny_icons).should be_true

          @sun = Data::Sun.new(@mid_time, @late_time)
          @result.sun = @sun
          @result.sunny?(@early_time,@sunny_icons).should be_false
        end

      end

    end

  end

end
