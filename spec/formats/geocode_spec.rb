require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Query::Format::Geocode do
  describe ".is?" do
    it "recognizes a valid format" do
      Barometer::Query::Format::Geocode.is?("New York, NY").should be_true
    end
  end
end
