require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require "addressable/uri"

params_in_body = lambda do |request_1, request_2|
  a1 = Addressable::URI.parse("?#{request_1.body}")
  a2 = Addressable::URI.parse("?#{request_2.body}")
  a1.query_values == a2.query_values
end

describe Barometer::Query::Converter::ToWoeId, vcr: {
  match_requests_on: [:method, :uri, params_in_body],
  cassette_name: "Converter::ToWoeId"
} do

  before { Barometer.yahoo_placemaker_app_id = YAHOO_KEY }

  it "converts :coordinates -> :woe_id" do
    query = Barometer::Query.new('40.756054,-73.986951')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converted_query = converter.call

    converted_query.q.should == '12761349'
    converted_query.format.should == :woe_id
  end

  it "converts :unknown -> :woe_id" do
    query = Barometer::Query.new('Paris, France')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converted_query = converter.call

    converted_query.q.should == '615702'
    converted_query.format.should == :woe_id
  end

  it "converts :postalcode -> :woe_id" do
    query = Barometer::Query.new('T5B 4M9')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converted_query = converter.call

    converted_query.q.should == '24354344'
    converted_query.format.should == :woe_id
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('10001')
    query.add_conversion(:geocode, 'New York, NY')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converted_query = converter.call

    converted_query.q.should == '2459115'
    converted_query.format.should == :woe_id
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('90210')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converter.call.should be_nil
  end
end
