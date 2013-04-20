require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Query::Format::NoaaStationId do
  describe ".is?" do
    it "returns false" do
      Barometer::Query::Format::NoaaStationId.is?("").should be_false
    end
  end
end
