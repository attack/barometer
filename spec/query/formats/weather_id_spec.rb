require_relative '../../spec_helper'

describe Barometer::Query::Format::WeatherID do
  it ".country_code" do
    Barometer::Query::Format::WeatherID.country_code(nil).should be_nil
    Barometer::Query::Format::WeatherID.country_code("i").should be_nil
    Barometer::Query::Format::WeatherID.country_code("USGA0000").should == "US"
    Barometer::Query::Format::WeatherID.country_code("CAAB0000").should == "CA"
    Barometer::Query::Format::WeatherID.country_code("SPXX0000").should == "ES"
  end

  describe ".is?" do
    it "recognizes a valid format" do
      Barometer::Query::Format::WeatherID.is?("USGA0028").should be_true
    end

    it "recognizes non-valid format" do
      Barometer::Query::Format::WeatherID.is?("invalid").should be_false
    end
  end

  describe "fixing country codes" do
    it "doesn't fix a correct code" do
      Barometer::Query::Format::WeatherID.send("_fix_country", "CA").should == "CA"
    end

    it "fixes an incorrect code" do
      Barometer::Query::Format::WeatherID.send("_fix_country", "SP").should == "ES"
    end
  end
end
