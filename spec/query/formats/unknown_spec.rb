require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Format::Unknown do
  describe ".is?" do
    it "returns true" do
      Barometer::Query::Format::Unknown.is?("New York, NY").should be_true
    end
  end
end
