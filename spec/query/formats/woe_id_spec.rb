require_relative '../../spec_helper'

describe Barometer::Query::Format::WoeID do
  before { Barometer.yahoo_placemaker_app_id = YAHOO_KEY }

  describe ".is?" do
    it "recognizes a valid 4 digit code format" do
      Barometer::Query::Format::WoeID.is?("8775").should be_true
    end

    it "recognizes a valid 6 digit code format" do
      Barometer::Query::Format::WoeID.is?("615702").should be_true
    end

    it "recognizes a valid 7 digit code format" do
      Barometer::Query::Format::WoeID.is?("2459115").should be_true
    end

    it "recognizes a valid 5 digit code with a prepended 'w'" do
      Barometer::Query::Format::WoeID.is?("w90210").should be_true
    end

    it "does not recognize a zip code" do
      Barometer::Query::Format::WoeID.is?("90210").should be_false
    end

    it "recognizes non-valid format" do
      Barometer::Query::Format::WoeID.is?("USGA0028").should be_false
    end
  end

  it ".convert_query" do
    query_no_conversion = "2459115"
    query = Barometer::Query.new(query_no_conversion)
    query.q.should == query_no_conversion

    query_with_conversion = "w90210"
    query = Barometer::Query.new(query_with_conversion)
    query.q.should_not == query_with_conversion
    query.q.should == "90210"
  end
end
