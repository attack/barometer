require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Query::Format::Icao do
  it ".country_code" do
    Barometer::Query::Format::Icao.country_code(nil).should be_nil
    Barometer::Query::Format::Icao.country_code("KSFO").should == "US"
    Barometer::Query::Format::Icao.country_code("CYYC").should == "CA"
    Barometer::Query::Format::Icao.country_code("ETAA").should == "DE"
  end

  describe ".is?" do
    it "recognizes a valid format" do
      Barometer::Query::Format::Icao.is?("KSFO").should be_true
    end

    it "recognizes non-valid format" do
      Barometer::Query::Format::Icao.is?("invalid").should be_false
    end
  end
end
