require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Measurement::ResultArray do
  describe "#<<" do
    it "raises an error with invalid data" do
      expect {
        subject << "invalid"
      }.to raise_error(ArgumentError)
    end

    it "adds Measurement::Result" do
      expect {
        subject <<  Barometer::Measurement::Result.new
      }.to change{ subject.count }.by(1)
    end
  end

  describe "#[]" do
    let(:result) { Barometer::Measurement::Result.new }
    before { subject << result }

    it "finds result by index when passed a number" do
      subject[0].should == result
    end

    it "finds result by using #for when not passed a number" do
      index = double(:index)
      subject.should_receive(:for).with(index)

      subject[index]
    end
  end

  describe "#for" do
    context "when there are no forecasts" do
      it "returns nil when there are no forecasts" do
        subject.size.should == 0
        subject.for(@tommorrow).should be_nil
      end
    end

    context "when there are forecasts" do
      let(:tommorrow) { Date.today + 1 }

      before do
        today = Date.today

        0.upto(3) do |i|
          forecast_measurement = Barometer::Measurement::Result.new
          forecast_measurement.date = today + i
          subject << forecast_measurement
        end
      end

      it "finds the date using a String" do
        subject.for(tommorrow.to_s).should == subject[1]
      end

      it "finds the date using a Date" do
        subject.for(tommorrow).should == subject[1]
      end

      it "finds the date using a DateTime" do
        subject.for(tommorrow.to_datetime).should == subject[1]
      end

      it "finds the date using a Time" do
        subject.for(tommorrow.to_time).should == subject[1]
      end

      it "finds the date using Data::LocalDateTime" do
        local_datetime = Data::LocalDateTime.parse(tommorrow.to_s)
        subject.for(local_datetime).should == subject[1]
      end

      it "finds nothing when there is not a match" do
        subject.for(Date.today - 1).should be_nil
      end
    end
  end
end
