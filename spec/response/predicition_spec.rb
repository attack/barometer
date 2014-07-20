require_relative '../spec_helper'

RSpec.describe Barometer::Response::Prediction do
  it { is_expected.to have_field(:starts_at).of_type(Time) }
  it { is_expected.to have_field(:ends_at).of_type(Time) }
  it { is_expected.to have_field(:high).of_type(Barometer::Data::Temperature) }
  it { is_expected.to have_field(:low).of_type(Barometer::Data::Temperature) }
  it { is_expected.to have_field(:pop).of_type(Float) }
  it { is_expected.to have_field(:icon).of_type(String) }
  it { is_expected.to have_field(:condition).of_type(String) }
  it { is_expected.to have_field(:sun).of_type(Barometer::Data::Sun) }

  describe "#date=" do
    let(:prediction) { Barometer::Response::Prediction.new }

    it "raises an error if unable to make a Date" do
      expect { prediction.date = 'invalid' }.to raise_error(ArgumentError)
    end

    it "sets the date to a passed in Date" do
      date = Date.new
      prediction.date = date
      expect(prediction.date).to eq date
    end

    it "sets the date to a passed in date string" do
      prediction.date = '2013-02-19'
      expect(prediction.date).to eq Date.new(2013, 02, 19)
    end

    it "sets :starts_at to 00:00:00 on given date" do
      expect(prediction.starts_at).to be_nil

      prediction.date = Date.new(2013, 02, 19)
      expect(prediction.starts_at.year).to eq 2013
      expect(prediction.starts_at.month).to eq 2
      expect(prediction.starts_at.day).to eq 19
      expect(prediction.starts_at.hour).to eq 0
      expect(prediction.starts_at.min).to eq 0
      expect(prediction.starts_at.sec).to eq 0
    end

    it "sets :ends_at to 23:59:59 on given date" do
      expect(prediction.ends_at).to be_nil

      prediction.date = Date.new(2013, 02, 19)
      expect(prediction.ends_at.year).to eq 2013
      expect(prediction.ends_at.month).to eq 2
      expect(prediction.ends_at.day).to eq 19
      expect(prediction.ends_at.hour).to eq 23
      expect(prediction.ends_at.min).to eq 59
      expect(prediction.ends_at.sec).to eq 59
    end
  end

  describe "#covers?" do
    let(:prediction) { Barometer::Response::Prediction.new }

    it "returns true if the valid_date range includes the given date" do
      prediction.date = Date.new(2009,05,05)
      expect(prediction.covers?(Time.utc(2009,5,5,12,0,0))).to be true
    end

    it "returns false if the valid_date range excludes the given date" do
      prediction.date = Date.new(2009,05,05)
      expect(prediction.covers?(Time.utc(2009,5,4,12,0,0))).to be false
    end
  end
end
