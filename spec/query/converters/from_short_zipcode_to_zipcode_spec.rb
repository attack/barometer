require_relative '../../spec_helper'

describe Barometer::Query::Converter::FromShortZipcodeToZipcode do
  it "converts :short_zipcode -> :zipcode" do
    query = Barometer::Query.new('90210')

    converter = Barometer::Query::Converter::FromShortZipcodeToZipcode.new(query)
    converted_query = converter.call

    converted_query.q.should == '90210'
    converted_query.format.should == :zipcode
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('Beverly Hills, CA, United States')
    query.add_conversion(:short_zipcode, '90210')

    converter = Barometer::Query::Converter::FromShortZipcodeToZipcode.new(query)
    converted_query = converter.call

    converted_query.q.should == '90210'
    converted_query.format.should == :zipcode
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('Beverly Hills, CA, United States')

    converter = Barometer::Query::Converter::FromShortZipcodeToZipcode.new(query)
    converter.call.should be_nil
  end
end
