require_relative '../../spec_helper'

RSpec.describe Barometer::Query::Converter::ToWeatherId, vcr: {
  match_requests_on: [:method, :uri],
  cassette_name: 'Converter::ToWeatherId'
} do

  it "converts :unknown -> :weather_id" do
    query = Barometer::Query.new('Paris, France')

    converter = Barometer::Query::Converter::ToWeatherId.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq 'FRXX0076'
    expect(converted_query.format).to eq :weather_id
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('KJFK')
    query.add_conversion(:geocode, 'New York, NY')

    converter = Barometer::Query::Converter::ToWeatherId.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq 'USNY0996'
    expect(converted_query.format).to eq :weather_id
  end

  it "does not convert any other format" do
    query = Barometer::Query.new('KJFK')

    converter = Barometer::Query::Converter::ToWeatherId.new(query)
    expect(converter.call).to be_nil
  end
end
