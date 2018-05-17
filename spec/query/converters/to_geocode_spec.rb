require_relative '../../spec_helper'

RSpec.describe Barometer::Query::Converter::ToGeocode, vcr: {
  match_requests_on: [
    :method,
    VCR.request_matchers.uri_without_param(:key)
  ],
  cassette_name: 'Converter::ToGeocode'
} do

  it "converts :short_zipcode -> :geocode" do
    query = Barometer::Query.new('90210')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq 'Beverly Hills, CA, United States'
    expect(converted_query.format).to eq :geocode
    expect(converted_query.geo.country_code).to eq 'US'
  end

  it "converts :zipcode -> :geocode" do
    query = Barometer::Query.new('90210-5555')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq 'Beverly Hills, CA, United States'
    expect(converted_query.format).to eq :geocode
    expect(converted_query.geo.country_code).to eq 'US'
  end

  it "converts :coordinates -> :geocode" do
    query = Barometer::Query.new('40.756054,-73.986951')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq 'Manhattan, NY, United States'
    expect(converted_query.format).to eq :geocode
    expect(converted_query.geo.country_code).to eq 'US'
  end

  it "converts :postalcode -> :geocode" do
    query = Barometer::Query.new('T5B 4M9')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq 'Edmonton, AB, Canada'
    expect(converted_query.format).to eq :geocode
    expect(converted_query.geo.country_code).to eq 'CA'
  end

  it "converts :icao -> :geocode" do
    query = Barometer::Query.new('KSFO')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq 'San Francisco, CA, United States'
    expect(converted_query.format).to eq :geocode
    expect(converted_query.geo.country_code).to eq 'US'
  end

  it "converts :unknown -> :geocode" do
    query = Barometer::Query.new('Paris, France')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq 'Paris, Île-de-France, France'
    expect(converted_query.format).to eq :geocode
    expect(converted_query.geo.country_code).to eq 'FR'
  end

  it "uses a previous coversion (if needed) on the query" do
    query = Barometer::Query.new('USGA0028')
    query.add_conversion(:icao, 'KSFO')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    converted_query = converter.call

    expect(converted_query.q).to eq 'San Francisco, CA, United States'
    expect(converted_query.format).to eq :geocode
    expect(converted_query.geo.country_code).to eq 'US'
  end

  it "does not convert :weather_id" do
    query = Barometer::Query.new('USGA0028')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    expect(converter.call).to be_nil
  end

  it "does not convert :woe_id" do
    query = Barometer::Query.new('615702')

    converter = Barometer::Query::Converter::ToGeocode.new(query)
    expect(converter.call).to be_nil
  end
end
