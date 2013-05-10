require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Format::Geocode do
  describe ".is?" do
    it "returns false" do
      Barometer::Query::Format::Geocode.is?("New York, NY").should be_false
    end
  end
end
