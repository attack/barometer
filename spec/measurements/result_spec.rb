require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Measurement::Result do
  describe "data fields" do
    it { should have_field(:temperature).of_type(Data::Temperature) }
    it { should have_field(:dew_point).of_type(Data::Temperature) }
    it { should have_field(:heat_index).of_type(Data::Temperature) }
    it { should have_field(:wind_chill).of_type(Data::Temperature) }
    it { should have_field(:high).of_type(Data::Temperature) }
    it { should have_field(:low).of_type(Data::Temperature) }

    it { should have_field(:wind).of_type(Data::Vector) }
    it { should have_field(:pressure).of_type(Data::Pressure) }
    it { should have_field(:visibility).of_type(Data::Distance) }

    it { should have_field(:pop).of_type(Float) }
    it { should have_field(:humidity).of_type(Float) }
    it { should have_field(:icon).of_type(String) }
    it { should have_field(:condition).of_type(String) }
    it { should have_field(:description).of_type(String) }

    it { should have_field(:current_at).of_type(Data::LocalDateTime) }
    it { should have_field(:updated_at).of_type(Data::LocalDateTime) }
    it { should have_field(:starts_at).of_type(Data::LocalDateTime) }
    it { should have_field(:ends_at).of_type(Data::LocalDateTime) }

    it { should have_field(:sun).of_type(Data::Sun) }
  end

  describe "#new" do
    it "initializes as metric" do
      result = Barometer::Measurement::Result.new
      result.should be_metric
    end

    it "initializes as imperial" do
      result = Barometer::Measurement::Result.new(false)
      result.should_not be_metric
    end
  end

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

  describe "#for_datetime?" do
    it "returns true if the valid_date range includes the given date" do
      subject.date = Date.new(2009,05,05)
      subject.for_datetime?(Data::LocalDateTime.new(2009,5,5,12,0,0)).should be_true
    end

    it "returns false if the valid_date range excludes the given date" do
      subject.date = Date.new(2009,05,05)
      subject.for_datetime?(Data::LocalDateTime.new(2009,5,4,12,0,0)).should be_false
    end
  end
end
