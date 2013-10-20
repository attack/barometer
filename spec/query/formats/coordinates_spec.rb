require_relative '../../spec_helper'

describe Barometer::Query::Format::Coordinates do
  describe ".is?" do
    it "returns true when valid" do
      Barometer::Query::Format::Coordinates.is?("40.756054,-73.986951").should be_true
    end

    it "returns false when not valid" do
      Barometer::Query::Format::Coordinates.is?("90210").should be_false
    end
  end
end
