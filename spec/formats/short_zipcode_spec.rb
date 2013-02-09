require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Query::Format::ShortZipcode do
  before(:each) do
    @valid = "90210"
    @invalid = "90210-5555"
  end

  describe "and class methods" do
    it "returns a format" do
      Barometer::Query::Format::ShortZipcode.format.should == :short_zipcode
    end

    it "returns a country" do
      Barometer::Query::Format::ShortZipcode.country_code.should == "US"
      Barometer::Query::Format::ShortZipcode.country_code("ignored").should == "US"
    end

    it "returns a regex" do
      Barometer::Query::Format::ShortZipcode.regex.should_not be_nil
      Barometer::Query::Format::ShortZipcode.regex.is_a?(Regexp).should be_true
    end

    describe "is?," do
      it "recognizes a valid format" do
        Barometer::Query::Format::ShortZipcode.is?(@valid).should be_true
      end

      it "recognizes non-valid format" do
        Barometer::Query::Format::ShortZipcode.is?(@invalid).should be_false
      end
    end

    it "stubs to" do
      Barometer::Query::Format::ShortZipcode.to.should be_nil
    end

    it "stubs convertable_formats" do
      Barometer::Query::Format::ShortZipcode.convertable_formats.should == []
    end

    it "doesn't convert" do
      query = Barometer::Query.new(@valid)
      Barometer::Query::Format::ShortZipcode.converts?(query).should be_false
    end
  end
end
