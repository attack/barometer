require_relative '../spec_helper'

describe Barometer::Response::Prediction do
  it { should have_field(:starts_at).of_type(Time) }
  it { should have_field(:ends_at).of_type(Time) }
  it { should have_field(:high).of_type(Barometer::Data::Temperature) }
  it { should have_field(:low).of_type(Barometer::Data::Temperature) }
  it { should have_field(:pop).of_type(Float) }
  it { should have_field(:icon).of_type(String) }
  it { should have_field(:condition).of_type(String) }
  it { should have_field(:sun).of_type(Barometer::Data::Sun) }

  describe "#date=" do
    it "raises an error if unable to make a Date" do
      expect { subject.date = 'invalid' }.to raise_error(ArgumentError)
    end

    it "sets the date to a passed in Date" do
      date = Date.new
      subject.date = date
      subject.date.should == date
    end

    it "sets the date to a passed in date string" do
      subject.date = '2013-02-19'
      subject.date.should == Date.new(2013, 02, 19)
    end

    it "sets :starts_at to 00:00:00 on given date" do
      subject.starts_at.should be_nil

      subject.date = Date.new(2013, 02, 19)
      subject.starts_at.year.should == 2013
      subject.starts_at.month.should == 2
      subject.starts_at.day.should == 19
      subject.starts_at.hour.should == 0
      subject.starts_at.min.should == 0
      subject.starts_at.sec.should == 0
    end

    it "sets :ends_at to 23:59:59 on given date" do
      subject.ends_at.should be_nil

      subject.date = Date.new(2013, 02, 19)
      subject.ends_at.year.should == 2013
      subject.ends_at.month.should == 2
      subject.ends_at.day.should == 19
      subject.ends_at.hour.should == 23
      subject.ends_at.min.should == 59
      subject.ends_at.sec.should == 59
    end
  end

  describe "#covers?" do
    it "returns true if the valid_date range includes the given date" do
      subject.date = Date.new(2009,05,05)
      subject.covers?(Time.utc(2009,5,5,12,0,0)).should be_true
    end

    it "returns false if the valid_date range excludes the given date" do
      subject.date = Date.new(2009,05,05)
      subject.covers?(Time.utc(2009,5,4,12,0,0)).should be_false
    end
  end
end
