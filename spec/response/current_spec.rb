require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Response::Current do
  it { should have_field(:observed_at).of_type(Time) }
  it { should have_field(:stale_at).of_type(Time) }
  it { should have_field(:temperature).of_type(Barometer::Data::Temperature) }
  it { should have_field(:dew_point).of_type(Barometer::Data::Temperature) }
  it { should have_field(:heat_index).of_type(Barometer::Data::Temperature) }
  it { should have_field(:wind_chill).of_type(Barometer::Data::Temperature) }
  it { should have_field(:wind).of_type(Barometer::Data::Vector) }
  it { should have_field(:pressure).of_type(Barometer::Data::Pressure) }
  it { should have_field(:visibility).of_type(Barometer::Data::Distance) }
  it { should have_field(:humidity).of_type(Float) }
  it { should have_field(:icon).of_type(String) }
  it { should have_field(:condition).of_type(String) }
  it { should have_field(:sun).of_type(Barometer::Data::Sun) }

  describe ".new" do
    it "initializes as metric" do
      result = Barometer::Response::Current.new
      result.should be_metric
    end

    it "initializes as imperial" do
      result = Barometer::Response::Current.new(false)
      result.should_not be_metric
    end
  end
end
