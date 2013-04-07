require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Query::Format::Coordinates do
  describe ".is?" do
    it "returns true when valid" do
      Barometer::Query::Format::Coordinates.is?("40.756054,-73.986951").should be_true
    end

    it "returns false when not valid" do
      Barometer::Query::Format::Coordinates.is?("90210").should be_false
    end
  end

  describe "parsing" do
    it "returns the latitude" do
      Barometer::Query::Format::Coordinates.parse_latitude("40.756054,-73.986951").should == "40.756054"
    end

    it "returns the longitude" do
      Barometer::Query::Format::Coordinates.parse_longitude("40.756054,-73.986951").should == "-73.986951"
    end

    it "returns nil when unknown" do
      Barometer::Query::Format::Coordinates.parse_longitude("90210").should be_nil
    end
  end
end
