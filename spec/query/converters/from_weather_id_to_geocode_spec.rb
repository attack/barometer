require_relative '../../spec_helper'

module Barometer::Query
  describe Converter::FromWeatherIdToGeocode, vcr: {
    match_requests_on: [:method, :uri],
    cassette_name: 'Converter::FromWeatherIdToGeocode'
  } do
    describe '.call' do
      it 'converts :weather_id -> :geocode' do
        query = Barometer::Query.new('USGA0028')

        converter = Converter::FromWeatherIdToGeocode.new(query)
        converted_query = converter.call

        expect( converted_query.q ).to eq 'Atlanta, GA, US'
        expect( converted_query.format ).to eq :geocode
        expect( converted_query.geo ).not_to be_nil
      end

      it 'uses a previous :weather_id coversion (if needed) on the query' do
        query = Barometer::Query.new('30301')
        query.add_conversion(:weather_id, 'USGA0028')

        converter = Converter::FromWeatherIdToGeocode.new(query)
        converted_query = converter.call

        expect( converted_query.q ).to eq 'Atlanta, GA, US'
        expect( converted_query.format ).to eq :geocode
        expect( converted_query.geo ).not_to be_nil
      end

      it 'does not convert any other format' do
        query = Barometer::Query.new('90210')

        converter = Converter::FromWeatherIdToGeocode.new(query)
        expect( converter.call ).to be_nil
      end
    end
  end
end
