require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Query::Format::Postalcode do
  it ".country_code" do
    Barometer::Query::Format::Postalcode.country_code(nil).should == "CA"
    Barometer::Query::Format::Postalcode.country_code("ignored").should == "CA"
  end

  describe ".is?" do
    it "recognizes a valid format" do
      Barometer::Query::Format::Postalcode.is?("T5B 4M9").should be_true
    end

    it "recognizes non-valid format" do
      Barometer::Query::Format::Postalcode.is?("90210").should be_false
    end
  end
end
