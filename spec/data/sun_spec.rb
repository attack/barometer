require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Data::Sun do
  let(:local_time_set) { Data::LocalTime.new.parse(Time.now + (60*60*8)) }
  let(:local_time_rise) { Data::LocalTime.new.parse(Time.now) }

  describe "#new" do
    it "sets the sunrise" do
      subject = Data::Sun.new(local_time_rise)
      subject.rise.should == local_time_rise
    end

    it "sets the sunset" do
      subject = Data::Sun.new(nil, local_time_set)
      subject.set.should == local_time_set
    end

    it "raises an error if sunrise is invalid" do
      expect {
        Data::Sun.new("", local_time_set)
      }.to raise_error ArgumentError
    end

    it "raises an error if sunset is invalid" do
      expect {
        Data::Sun.new(local_time_rise, "")
      }.to raise_error ArgumentError
    end
  end

  describe "#nil?" do
    it "returns true if nothing is set" do
      subject.nil?.should be_true
    end

    it "returns false if sunrise is set" do
      subject.rise = local_time_rise
      subject.nil?.should be_false
    end

    it "returns false if sunset is set" do
      subject.set = local_time_set
      subject.nil?.should be_false
    end
  end

  describe "comparisons" do
    let(:now) { Time.local(2009,5,5,11,40,00) }
    let(:early_time) { Data::LocalTime.new.parse(now - (60*60*8)) }
    let(:mid_time) { Data::LocalTime.new.parse(now) }
    let(:late_time) { Data::LocalTime.new.parse(now + (60*60*8)) }

    describe "#after_rise?" do
      it "requires a LocalTime object" do
        expect {
          subject.after_rise?("invalid")
        }.to raise_error(ArgumentError)
      end

      it "returns true when after sun rise" do
        subject = Data::Sun.new(early_time, late_time)
        subject.after_rise?(mid_time).should be_true
      end

      it "returns false when before sun rise" do
        subject = Data::Sun.new(mid_time, late_time)
        subject.after_rise?(early_time).should be_false
      end
    end

    describe "#before_set?" do
      it "requires a LocalTime object" do
        expect {
          subject.before_set?("invalid")
        }.to raise_error(ArgumentError)
      end

      it "returns true when before sun set" do
        subject = Data::Sun.new(early_time, late_time)
        subject.before_set?(mid_time).should be_true
      end

      it "returns false when before sun set" do
        subject = Data::Sun.new(early_time, mid_time)
        subject.before_set?(late_time).should be_false
      end
    end
  end

  describe "#rise=" do
    it "requires Data::LocalTime" do
      expect {
        subject.rise = ""
      }.to raise_error(ArgumentError)
    end

    it "allows nil" do
      expect {
        subject.rise = nil
      }.not_to raise_error(ArgumentError)
    end

    it "sets the rise time" do
      subject.rise = local_time_rise
      subject.rise.should == local_time_rise
    end
  end

  describe "#set=" do
    it "requires Data::LocalTime" do
      expect {
        subject.set = ""
      }.to raise_error(ArgumentError)
    end

    it "allows nil" do
      expect {
        subject.set = nil
      }.not_to raise_error(ArgumentError)
    end

    it "sets the set time" do
      subject.set = local_time_set
      subject.set.should == local_time_set
    end
  end

  describe "#to_s" do
    it "defaults as blank" do
      subject.to_s.should == ""
    end

    it "returns the sunrise time" do
      subject.rise = local_time_rise
      subject.to_s.should == "rise: #{local_time_rise.to_s}"
    end

    it "returns the sunset time" do
      subject.set = local_time_set
      subject.to_s.should == "set: #{local_time_set.to_s}"
    end

    it "returns both times" do
      subject.rise = local_time_rise
      subject.set = local_time_set
      subject.to_s.should == "rise: #{local_time_rise.to_s}, set: #{local_time_set.to_s}"
    end
  end
end
