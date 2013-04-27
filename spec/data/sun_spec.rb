require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Data::Sun do
  let(:local_time_set) { Time.now + (60*60*8) }
  let(:local_time_rise) { Time.now }

  describe "#new" do
    it "sets the sunrise" do
      sun = Barometer::Data::Sun.new(local_time_rise)
      sun.rise.should == local_time_rise
    end

    it "sets the sunset" do
      sun = Barometer::Data::Sun.new(nil, local_time_set)
      sun.set.should == local_time_set
    end

    it "raises an error if sunrise is invalid" do
      expect {
        Barometer::Data::Sun.new("", local_time_set)
      }.to raise_error ArgumentError
    end

    it "raises an error if sunset is invalid" do
      expect {
        Barometer::Data::Sun.new(local_time_rise, "")
      }.to raise_error ArgumentError
    end
  end

  describe "#nil?" do
    it "returns true if nothing is set" do
      sun = Barometer::Data::Sun.new(nil, nil)
      sun.nil?.should be_true
    end

    it "returns false if sunrise is set" do
      sun = Barometer::Data::Sun.new(local_time_rise, nil)
      sun.nil?.should be_false
    end

    it "returns false if sunset is set" do
      sun = Barometer::Data::Sun.new(nil, local_time_set)
      sun.nil?.should be_false
    end
  end

  describe "comparisons" do
    let(:now) { Time.local(2009,5,5,11,40,00) }
    let(:early_time) { now - (60*60*8) }
    let(:mid_time) { now }
    let(:late_time) { now + (60*60*8) }

    describe "#after_rise?" do
      it "requires a LocalDateTime object" do
        sun = Barometer::Data::Sun.new(early_time, late_time)
        expect {
          sun.after_rise?("invalid")
        }.to raise_error(ArgumentError)
      end

      it "returns true when after sun rise" do
        sun = Barometer::Data::Sun.new(early_time, late_time)
        sun.after_rise?(mid_time).should be_true
      end

      it "returns false when before sun rise" do
        sun = Barometer::Data::Sun.new(mid_time, late_time)
        sun.after_rise?(early_time).should be_false
      end
    end

    describe "#before_set?" do
      it "requires a LocalDateTime object" do
        sun = Barometer::Data::Sun.new(early_time, late_time)
        expect {
          sun.before_set?("invalid")
        }.to raise_error(ArgumentError)
      end

      it "returns true when before sun set" do
        sun = Barometer::Data::Sun.new(early_time, late_time)
        sun.before_set?(mid_time).should be_true
      end

      it "returns false when before sun set" do
        sun = Barometer::Data::Sun.new(early_time, mid_time)
        sun.before_set?(late_time).should be_false
      end
    end
  end

  describe "#to_s" do
    it "defaults as blank" do
      sun = Barometer::Data::Sun.new()
      sun.to_s.should == ""
    end

    it "returns the sunrise time" do
      sun = Barometer::Data::Sun.new(local_time_rise)
      sun.to_s.should == "rise: #{local_time_rise.strftime('%H:%M')}"
    end

    it "returns the sunset time" do
      sun = Barometer::Data::Sun.new(nil, local_time_set)
      sun.to_s.should == "set: #{local_time_set.strftime('%H:%M')}"
    end

    it "returns both times" do
      sun = Barometer::Data::Sun.new(local_time_rise, local_time_set)
      sun.to_s.should == "rise: #{local_time_rise.strftime('%H:%M')}, set: #{local_time_set.strftime('%H:%M')}"
    end
  end
end
