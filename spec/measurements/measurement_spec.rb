require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Measurement do
  describe "#new" do
    its(:forecast) { should be_a Barometer::Measurement::ResultArray }
    its(:current) { should be_a Barometer::Measurement::Result }
    its(:metric) { should be_true }
    its(:weight) { should == 1 }
    its(:requested_at) { should be_a(Time) }
  end

  describe "data fields" do
    it { should have_field(:query).of_type(String) }
    it { should have_field(:weight).of_type(Integer) }
    it { should have_field(:status_code).of_type(Integer) }
    it { should have_field(:published_at).of_type(Data::LocalDateTime) }
  end

  describe "#success?" do
    it "returns true if :status_code == 200" do
      subject.status_code = 200
      subject.should be_success
    end

    it "returns false if :status_code does not == 200" do
      subject.status_code = nil
      subject.should_not be_success

      subject.status_code = 406
      subject.should_not be_success
    end
  end

  describe "#complete?" do
    it "returns true when the current temperature has been set" do
      subject.current.temperature << 10
      subject.should be_complete
    end

    it "returns true when the current temperature has not been set" do
      subject.should_not be_complete
    end
  end

  describe "#build_forecast" do
    it "yields a new measurement" do
      expect { |b|
        subject.build_forecast(&b)
      }.to yield_with_args(Barometer::Measurement::Result)
    end

    it "adds the new measurement to forecast array" do
      expect {
        subject.build_forecast do
        end
      }.to change{ subject.forecast.count }.by(1)
    end
  end

  describe "when searching forecasts using 'for'" do
    before(:each) do
      @measurement = Barometer::Measurement.new

      1.upto(4) do |i|
        forecast_measurement = Barometer::Measurement::Result.new
        forecast_measurement.date = Date.parse((Time.now + (i * 60 * 60 * 24)).to_s)
        @measurement.forecast << forecast_measurement
      end
      @measurement.forecast.size.should == 4

      @tommorrow = (Time.now + (60 * 60 * 24))
    end

    it "returns nil when there are no forecasts" do
      @measurement.forecast = Barometer::Measurement::ResultArray.new
      @measurement.forecast.size.should == 0
      @measurement.for.should be_nil
    end

    it "finds the date using a String" do
      tommorrow = @tommorrow.to_s
      tommorrow.class.should == String
      @measurement.for(tommorrow).should == @measurement.forecast.first
    end

    it "finds the date using a Date" do
      tommorrow = Date.parse(@tommorrow.to_s)
      tommorrow.class.should == Date
      @measurement.for(tommorrow).should == @measurement.forecast.first
    end

    it "finds the date using a DateTime" do
      tommorrow = DateTime.parse(@tommorrow.to_s)
      tommorrow.class.should == DateTime
      @measurement.for(tommorrow).should == @measurement.forecast.first
    end

    it "finds the date using a Time" do
      @tommorrow.class.should == Time
      @measurement.for(@tommorrow).should == @measurement.forecast.first
    end

    it "finds the date using Data::LocalDateTime" do
      tommorrow = Data::LocalDateTime.parse(@tommorrow.to_s)
      tommorrow.class.should == Data::LocalDateTime
      @measurement.for(tommorrow).should == @measurement.forecast.first
    end

    it "finds nothing when there is not a match" do
      yesterday = (Time.now - (60 * 60 * 24))
      yesterday.class.should == Time
      @measurement.for(yesterday).should be_nil
    end
  end
end
