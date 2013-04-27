require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Format::ShortZipcode do
  it ".country_code" do
    Barometer::Query::Format::ShortZipcode.country_code(nil).should == "US"
    Barometer::Query::Format::ShortZipcode.country_code("ignored").should == "US"
  end

  describe ".is?" do
    it "recognizes a valid format" do
      Barometer::Query::Format::ShortZipcode.is?("90210").should be_true
    end

    it "recognizes non-valid format" do
      Barometer::Query::Format::ShortZipcode.is?("90210-5555").should be_false
    end
  end
end
