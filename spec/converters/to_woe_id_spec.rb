require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require "addressable/uri"

params_in_body = lambda do |request_1, request_2|
  a1 = Addressable::URI.parse("?#{request_1.body}")
  a2 = Addressable::URI.parse("?#{request_2.body}")
  a1.query_values == a2.query_values
end

describe Barometer::Converter::ToWoeId, :vcr => {
  :match_requests_on => [:method, :uri, params_in_body],
  :cassette_name => "Converter::ToWoeId"
} do

  before { Barometer.yahoo_placemaker_app_id = YAHOO_KEY }

  it "converts :coordinates -> :woe_id" do
    query = Barometer::Query.new('40.756054,-73.986951')
    query.format = :coordinates

    converter = Barometer::Converter::ToWoeId.new(query)
    converted_query = converter.call

    converted_query.q.should == '12589342'
    converted_query.country_code.should be_nil
    converted_query.format.should == :woe_id
    converted_query.geo.should be_nil
  end

  it "converts :geocode -> :woe_id" do
    query = Barometer::Query.new('New York, NY')
    query.format = :geocode

    converter = Barometer::Converter::ToWoeId.new(query)
    converted_query = converter.call

    converted_query.q.should == '2459115'
    converted_query.country_code.should be_nil
    converted_query.format.should == :woe_id
    converted_query.geo.should be_nil
  end

  it "converts :postalcode -> :woe_id" do
    query = Barometer::Query.new('T5B 4M9')
    query.format = :postalcode

    converter = Barometer::Converter::ToWoeId.new(query)
    converted_query = converter.call

    converted_query.q.should == '8676'
    converted_query.country_code.should == 'CA'
    converted_query.format.should == :woe_id
    converted_query.geo.should be_nil
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('10001')
    query.format = :short_zipcode
    query.add_conversion(:geocode, 'New York, NY')

    converter = Barometer::Converter::ToWoeId.new(query)
    converted_query = converter.call

    converted_query.q.should == '2459115'
    converted_query.country_code.should == 'US'
    converted_query.format.should == :woe_id
    converted_query.geo.should be_nil
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('90210')
    query.format = :short_zipcode

    converter = Barometer::Converter::ToWoeId.new(query)
    converter.call.should be_nil
  end
end
