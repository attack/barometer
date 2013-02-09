require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Measurement::ResultArray do
  describe "instance methods" do
    before(:each) do
      @array = Barometer::Measurement::ResultArray.new
    end

    describe "'<<'" do
      it "requires Barometer::Measurement::Result" do
        lambda { @array << "invalid" }.should raise_error(ArgumentError)
      end

      it "adds ForecastMeasurement" do
        @array.size.should == 0
        forecast = Barometer::Measurement::Result.new
        @array << forecast
        @array.size.should == 1
      end
    end

    describe "when searching forecasts using 'for'" do
      before(:each) do
        1.upto(4) do |i|
          forecast_measurement = Barometer::Measurement::Result.new
          forecast_measurement.date = Date.parse((Time.now + (i * 60 * 60 * 24)).to_s)
          @array << forecast_measurement
        end
        @array.size.should == 4

        @tommorrow = (Time.now + (60 * 60 * 24))
      end

      it "returns nil when there are no forecasts" do
        @array = Barometer::Measurement::ResultArray.new
        @array.size.should == 0
        @array.for(@tommorrow).should be_nil
      end

      it "finds the date using a String" do
        tommorrow = @tommorrow.to_s
        tommorrow.class.should == String
        @array.for(tommorrow).should == @array.first
      end

      it "finds the date using a Date" do
        tommorrow = Date.parse(@tommorrow.to_s)
        tommorrow.class.should == Date
        @array.for(tommorrow).should == @array.first
      end

      it "finds the date using a DateTime" do
        tommorrow = DateTime.parse(@tommorrow.to_s)
        tommorrow.class.should == DateTime
        @array.for(tommorrow).should == @array.first
      end

      it "finds the date using a Time" do
        @tommorrow.class.should == Time
        @array.for(@tommorrow).should == @array.first
      end

      it "finds the date using Data::LocalDateTime" do
        tommorrow = Data::LocalDateTime.parse(@tommorrow.to_s)
        tommorrow.class.should == Data::LocalDateTime
        @array.for(tommorrow).should == @array.first
      end

      it "finds nothing when there is not a match" do
        yesterday = (Time.now - (60 * 60 * 24))
        yesterday.class.should == Time
        @array.for(yesterday).should be_nil
      end

      it "finds using '[]'" do
        tommorrow = @tommorrow.to_s
        tommorrow.class.should == String
        @array[tommorrow].should == @array.first
      end
    end
  end

  describe "simple questions" do
    before(:each) do
      @array = Barometer::Measurement::ResultArray.new
      @now = Time.utc(2009,5,5,10,30,25)

      @sun_icons = %w(sunny)

      0.upto(1) do |i|
        forecast_measurement = Barometer::Measurement::Result.new
        forecast_measurement.date = Date.parse((@now + (i * 60 * 60 * 24)).to_s)
        wind = Data::Speed.new
        wind << (i * 5)
        forecast_measurement.wind = wind
        forecast_measurement.sun = Data::Sun.new(
          Data::LocalTime.parse("9:00 am"), Data::LocalTime.parse("3:00 pm"))
        forecast_measurement.icon = "sunny"
        forecast_measurement.pop = 40
        forecast_measurement.humidity = 95
        @array << forecast_measurement
      end
      @array.size.should == 2
      @tommorrow = (@now + (60 * 60 * 24))
      @yesterday = (@now - (60 * 60 * 24))
      @earlier = (@now - (60 * 60 * 3))
      @later = (@now + (60 * 60 * 6))
    end

    it "answers windy?" do
      @array.windy?(@tommorrow).should be_false
      @array.windy?(@tommorrow,1).should be_true
      @array.windy?(@yesterday).should be_nil
    end

    it "answers day?" do
      @array.day?(@yesterday).should be_nil
      @array.day?(@earlier).should be_false
      @array.day?(@later).should be_false
      @array.day?(@tommorrow).should be_true
      @array.day?(@now).should be_true
    end

    it "answers sunny?" do
      @array.sunny?(@tommorrow,%w(rain)).should be_false
      @array.sunny?(@tommorrow,@sun_icons).should be_true
      @array.sunny?(@yesterday).should be_nil
    end

    describe "wet?" do
      it "answers via pop" do
        @array.wet?(@tommorrow).should be_false
        @array.wet?(@tommorrow,nil,50).should be_false
        @array.wet?(@tommorrow,nil,30).should be_true
      end

      it "answers via humidity" do
        @array.wet?(@tommorrow).should be_false
        @array.wet?(@tommorrow,nil,50,99).should be_false
        @array.wet?(@tommorrow,nil,50,90).should be_true
      end

      it "answers via icon" do
        @array.wet?(@tommorrow,%w(rain)).should be_false
        # pretend that "sun" means wet
        @array.wet?(@tommorrow,@sun_icons).should be_true
      end
    end
  end
end
