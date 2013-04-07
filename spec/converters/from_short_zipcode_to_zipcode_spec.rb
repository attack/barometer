require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Converter::FromShortZipcodeToZipcode do
  it "converts :short_zipcode -> :zipcode" do
    query = Barometer::Query.new('90210')
    query.format = :short_zipcode

    converter = Barometer::Converter::FromShortZipcodeToZipcode.new(query)
    converted_query = converter.call

    converted_query.q.should == '90210'
    converted_query.format.should == :zipcode
    converted_query.country_code.should == 'US'
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('Beverly Hills, CA, United States')
    query.format = :geocode
    query.add_conversion(:short_zipcode, '90210')

    converter = Barometer::Converter::FromShortZipcodeToZipcode.new(query)
    converted_query = converter.call

    converted_query.q.should == '90210'
    converted_query.format.should == :zipcode
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('Beverly Hills, CA, United States')
    query.format = :geocode

    converter = Barometer::Converter::FromShortZipcodeToZipcode.new(query)
    converter.call.should be_nil
  end
end
