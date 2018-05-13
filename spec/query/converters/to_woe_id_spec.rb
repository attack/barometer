require_relative '../../spec_helper'

RSpec.describe Barometer::Query::Converter::ToWoeId, vcr: {
  cassette_name: 'Converter::ToWoeId'
} do

  it 'converts :short_zipcode -> :woe_id' do
    query = Barometer::Query.new('90210')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converted_query = converter.call

    expect( converted_query.q ).to eq '12795711'
    expect( converted_query.format ).to eq :woe_id
  end

  it 'converts :coordinates -> :woe_id' do
    query = Barometer::Query.new('40.756054,-73.986951')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converted_query = converter.call

    expect( converted_query.q ).to eq '91568254'
    expect( converted_query.format ).to eq :woe_id
  end

  it 'converts :unknown -> :woe_id' do
    query = Barometer::Query.new('Paris, France')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converted_query = converter.call

    expect( converted_query.q ).to eq '615702'
    expect( converted_query.format ).to eq :woe_id
  end

  it 'converts :postalcode -> :woe_id' do
    query = Barometer::Query.new('T5B 4M9')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converted_query = converter.call

    expect( converted_query.q ).to eq '24354344'
    expect( converted_query.format ).to eq :woe_id
  end

  it 'uses a previous coversion (if needed) on the query' do
    query = Barometer::Query.new('KJFK')
    query.add_conversion(:geocode, 'New York, NY')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    converted_query = converter.call

    expect( converted_query.q ).to eq '2459115'
    expect( converted_query.format ).to eq :woe_id
  end

  it 'does not convert any other format' do
    query = Barometer::Query.new('KJFK')

    converter = Barometer::Query::Converter::ToWoeId.new(query)
    expect( converter.call ).to be_nil
  end
end
