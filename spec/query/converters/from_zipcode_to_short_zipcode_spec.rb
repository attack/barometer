require_relative '../../spec_helper'

RSpec.describe Barometer::Query::Converter::FromZipcodeToShortZipcode do
  it "converts :zipcode -> :short_zipcode" do
    query = Barometer::Query.new('90210-5555')

    converter = Barometer::Query::Converter::FromZipcodeToShortZipcode.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq '90210'
    expect(converted_query.format).to eq :short_zipcode
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('Beverly Hills, CA, United States')
    query.add_conversion(:zipcode, '90210-5555')

    converter = Barometer::Query::Converter::FromZipcodeToShortZipcode.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq '90210'
    expect(converted_query.format).to eq :short_zipcode
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('Beverly Hills, CA, United States')

    converter = Barometer::Query::Converter::FromZipcodeToShortZipcode.new(query)
    expect(converter.call).to be_nil
  end
end
