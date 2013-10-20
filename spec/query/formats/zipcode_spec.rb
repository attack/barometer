require_relative '../../spec_helper'

describe Barometer::Query::Format::Zipcode do
  it ".country_code" do
    Barometer::Query::Format::Zipcode.country_code(nil).should == "US"
    Barometer::Query::Format::Zipcode.country_code("ignored").should == "US"
  end

  describe ".is?" do
    it "recognizes a valid format" do
      Barometer::Query::Format::Zipcode.is?("90210-5555").should be_true
    end

    it "recognizes non-valid format" do
      Barometer::Query::Format::Zipcode.is?("invalid").should be_false
    end
  end
end
